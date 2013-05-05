#ifndef OPTIONS__
#define OPTIONS__

#include <cerrno>
#include <cstdlib>
#include <utility>
#include <limits>
#include <vector>
#include <memory>
#include <string>
#include <sstream>
#include <stdexcept>
#include <unordered_map>

namespace options
{

  typedef std::vector<std::string> string_vector;

  enum option_flags
    {
      none     = 0,
      required = 1 << 0,
    };

  enum parser_flags
    {
      present  = 1 << 10,
      stop_at_unknown = 1 << 20,
    };

  class parser;

  class option_error : public std::runtime_error
  {

  public:

    option_error(int offset, const string_vector &args):
      std::runtime_error(make_option_error(offset, args))
    {
    }

    option_error(const std::string &msg):
      std::runtime_error(msg)
    {
    }

  private:

    static std::string make_option_error(int offset, const string_vector &args)
    {
      std::ostringstream buffer;
      buffer << args[offset];
      buffer << ": missing option value";
      return buffer.str();
    }

  };

  class option_parser
  {

  public:

    parser &parent;
    int flags;

    option_parser(parser &p, int f):
      parent(p),
      flags(f)
    {
    }

    virtual ~option_parser()
    {
    }

    virtual size_t operator()(size_t offset, const string_vector &args) const = 0;

  };

  template < typename T >
  class option
  {
  public:
    size_t operator()(T &dest, size_t offset, const string_vector &args, parser &) const
    {
      std::istringstream s { args[offset] };
      s >> dest;
      return offset + 1;
    }
  };

  template <>
  class option<bool>
  {
  public:
    size_t operator()(bool &dest, size_t offset, const string_vector &, parser &) const
    {
      dest = true;
      return offset + 1;
    }
  };

  template < typename Char, typename Traits, typename Allocator >
  class option< std::basic_string<Char, Traits, Allocator> >
  {
  public:
    size_t operator()(std::basic_string<Char, Traits, Allocator> &dest,
                      size_t offset,
                      const string_vector &args,
                      parser &) const
    {
      dest = args[offset];
      return offset + 1;
    }
  };

  template < typename T >
  class integer
  {
  public:
    size_t operator()(T &dest, size_t offset, const string_vector &args, parser &) const
    {
      char *ptr = NULL;
      long value = std::strtol(args[offset].c_str(), &ptr, 0);
      if ((ptr == NULL) || (*ptr != '\0'))
        {
          throw option_error(args[offset] + ": invalid value");
        }
      if ((errno == ERANGE)
          || (((long)std::numeric_limits<T>::max()) < value)
          || (((long)std::numeric_limits<T>::min()) > value))
        {
          throw option_error(args[offset] + ": out of range");
        }
      dest = value;
      return offset + 1;
    }
  };

  template < typename T >
  class unsigned_integer
  {
  public:
    size_t operator()(T &dest, size_t offset, const string_vector &args, parser &) const
    {
      char *ptr = NULL;
      unsigned long value = std::strtoul(args[offset].c_str(), &ptr, 0);
      if ((ptr == NULL) || (*ptr != '\0'))
        {
          throw option_error(args[offset] + ": invalid value");
        }
      if ((errno == ERANGE) || (((unsigned long)std::numeric_limits<T>::max()) < value))
        {
          throw option_error(args[offset] + ": out of range");
        }
      dest = value;
      return offset + 1;
    }
  };

  template < typename T >
  class number;

  template <>
  class number<float>
  {
  public:
    size_t operator()(float &dest, size_t offset, const string_vector &args, parser &) const
    {
      char *ptr = NULL;
      dest = std::strtof(args[offset].c_str(), &ptr);
      if ((ptr == NULL) || (*ptr != '\0'))
        {
          throw option_error(args[offset] + ": invalid value");
        }
      if (errno == ERANGE)
        {
          throw option_error(args[offset] + ": out of range");
        }
      return offset + 1;
    }    
  };

  template <>
  class number<double>
  {
  public:
    size_t operator()(double &dest, size_t offset, const string_vector &args, parser &) const
    {
      char *ptr = NULL;
      dest = std::strtod(args[offset].c_str(), &ptr);
      if ((ptr == NULL) || (*ptr != '\0'))
        {
          throw option_error(args[offset] + ": invalid value");
        }
      if (errno == ERANGE)
        {
          throw option_error(args[offset] + ": out of range");
        }
      return offset + 1;
    }
  };

  template <>
  class number<long double>
  {
  public:
    size_t operator()(long double &dest, size_t offset, const string_vector &args, parser &) const
    {
      char *ptr = NULL;
      dest = std::strtold(args[offset].c_str(), &ptr);
      if ((ptr == NULL) || (*ptr != '\0'))
        {
          throw option_error(args[offset] + ": invalid value");
        }
      if (errno == ERANGE)
        {
          throw option_error(args[offset] + ": out of range");
        }
      return offset + 1;
    }    
  };

  template <>
  class option<int>
  {
  public:
    size_t operator()(int &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return integer<int>{}(dest, offset, args, parser);
    };
  };

  template <>
  class option<unsigned int>
  {
  public:
    size_t operator()(unsigned int &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return unsigned_integer<unsigned int>{}(dest, offset, args, parser);
    };
  };

  template <>
  class option<long>
  {
  public:
    size_t operator()(long &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return integer<long>{}(dest, offset, args, parser);
    };
  };

  template <>
  class option<unsigned long>
  {
  public:
    size_t operator()(unsigned long &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return unsigned_integer<unsigned long>{}(dest, offset, args, parser);
    };
  };

  template <>
  class option<float>
  {
  public:
    size_t operator()(float &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return number<float>{}(dest, offset, args, parser);
    }
  };

  template <>
  class option<double>
  {
  public:
    size_t operator()(double &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return number<double>{}(dest, offset, args, parser);
    }
  };

  template <>
  class option<long double>
  {
  public:
    size_t operator()(long double &dest, size_t offset, const string_vector &args, parser &parser) const
    {
      return number<long double>{}(dest, offset, args, parser);
    }
  };

  template < typename T >
  class typed_option_parser : public option_parser
  {

  public:

    typed_option_parser(parser &p, T &t, int f):
      option_parser(p, f),
      dest(t)
    {
    }

    size_t operator()(size_t offset, const string_vector &args) const
    {
      if ((offset + 1) == args.size())
        {
          throw option_error(offset, args);
        }
      return option<T>{}(dest, offset + 1, args, parent);
    }

  private:
    T &dest;

  };

  template <>
  class typed_option_parser<bool> : public option_parser
  {

  public:

    typed_option_parser(parser &p, bool &t, int f):
      option_parser(p, f),
      dest(t)
    {
    }

    size_t operator()(size_t offset, const string_vector &args) const
    {
      return option<bool>{}(dest, offset, args, parent);
    }

  private:
    bool &dest;

  };

  class parser
  {

  public:

    string_vector unknown;

    parser():
      unknown(),
      parsers_short(),
      parsers_long()
    {
    }

    parser(parser &&p):
      unknown(),
      parsers_short(),
      parsers_long()
    {
      p.swap(*this);
    }

    parser(const parser &p):
      unknown(p.unknown),
      parsers_short(p.parsers_short),
      parsers_long(p.parsers_long)
    {
    }

    parser &operator=(parser &&p)
    {
      p.swap(*this);
      return *this;
    }

    parser &operator=(const parser &p)
    {
      parser(p).swap(*this);
      return *this;
    }

    template < typename T >
    void add(const std::string &short_name, const std::string &long_name, T &dest, int flags = none)
    {
      auto op = std::make_shared< typed_option_parser<T> >(*this, dest, flags);
      if (!short_name.empty())
        {
          parsers_short.insert(std::make_pair(short_name, op));
        }
      try
        {
          parsers_long.insert(std::make_pair(long_name, op));
        }
      catch (...)
        {
          parsers_short.erase(short_name);
          throw;
        }
    }

    size_t parse(size_t argc, char **argv, int flags = none)
    {
      string_vector args;
      option_parser *parser;
      size_t i;

      clear_parsers();
      args.reserve(argc);
      i = 1;
      while (i < argc)
        {
          args.emplace_back(argv[i++]);
        }

      i = 0;
      while (i < args.size())
        {
          if (!(parser = get(args[i])))
            {
              if (flags & stop_at_unknown)
                {
                  break;
                }
              unknown.emplace_back(args[i++]);
            }
          else
            {
              validate_parser(args[i]);
              i = (*parser)(i, args);
            }
        }

      check_parsers();
      return i + 1;
    }

    void swap(parser &p)
    {
      unknown.swap(p.unknown);
      parsers_short.swap(p.parsers_short);
      parsers_long.swap(p.parsers_long);
    }

    void clear()
    {
      unknown.clear();
      parsers_short.clear();
      parsers_long.clear();
    }

    option_parser *get(const std::string &opt_name) const
    {
      auto it = parsers_short.find(opt_name);
      if (it == parsers_short.end())
        {
          it = parsers_long.find(opt_name);
          if (it == parsers_long.end())
            {
              return nullptr;
            }
        }
      return it->second.get();
    }

    bool is_option(const std::string &opt_name) const
    {
      return get(opt_name) != nullptr;
    }

  private:
    typedef std::unordered_map< std::string, std::shared_ptr<option_parser> > parser_map;

    parser_map parsers_short;
    parser_map parsers_long;

    void clear_parsers()
    {
      clear_parsers(parsers_short);
      clear_parsers(parsers_long);
    }

    void clear_parsers(parser_map &map)
    {
      for (auto &entry : map)
        {
          entry.second->flags &= ~present;
        }
    }

    void validate_parser(const std::string &option)
    {
      validate_parser(option, parsers_short);
      validate_parser(option, parsers_long);
    }

    void validate_parser(const std::string &option, parser_map &map)
    {
      auto it = map.find(option);
      if (it != map.end())
        {
          it->second->flags |= present;
        }
    }

    void check_parsers()
    {
      check_parsers(parsers_short);
      check_parsers(parsers_long);
    }

    void check_parsers(parser_map &map)
    {
      for (const auto &entry : map)
        {
          if ((entry.second->flags & required) && !(entry.second->flags & present))
            {
              throw option_error(entry.first + ": missing required option");
            }
        }
    }

  };

  inline parser &default_parser()
  {
    static parser p;
    return p;
  }

  template < typename T >
  inline void add(const char *short_name, const char *long_name, T &dest, int flags = none)
  {
    default_parser().add(short_name, long_name, dest, flags);
  }

  template < typename T >
  inline void add(const char *long_name, T &dest, int flags = none)
  {
    default_parser().add("", long_name, dest, flags);
  }

  inline size_t parse(size_t argc, char **argv, int flags = none)
  {
    return default_parser().parse(argc, argv, flags);
  }

  inline void clear()
  {
    default_parser().clear();
  }

  inline const string_vector &unknown()
  {
    return default_parser().unknown;
  }

  template < typename T, typename Allocator >
  class option< std::vector<T, Allocator> >
  {
  public:
    size_t operator()(std::vector<T, Allocator> &dest,
                      size_t offset,
                      const string_vector &args,
                      parser &parser) const
    {
      while ((offset < args.size()) && !parser.is_option(args[offset]))
        {
          T t;
          option<T>{}(t, offset, args, parser);
          dest.emplace_back(std::move(t));
          ++offset;
        }
      return offset;
    }
  };
}

namespace std
{

  inline void swap(options::parser &p1, options::parser &p2)
  {
    p1.swap(p2);
  }

}

#endif /* OPTIONS__ */
