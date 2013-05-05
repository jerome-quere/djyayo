#include <sstream>

#include "Command.hpp"

namespace Spdj
{
  Command::Command()
  {
  }

  Command::~Command()
  {
  }

  Command::Command(const Command& obj)
  {
    operator=(obj);
  }

  Command& Command::operator=(const Command& obj)
  {
    _name = obj._name;
    _args = obj._args;
    return (*this);
  }

  const std::string& Command::getName() const
  {
    return (_name);
  }

  const std::vector<std::string>& Command::getArgs() const
  {
    return _args;
  }

  void Command::setName(const std::string& name)
  {
    _name = name;
  }

  bool Command::parse(const std::string& str)
  {
    std::stringstream s;
    std::string arg;

    s.str(str);
    s >> _name;
    while (s.good())
      {
	s >> arg;
	_args.push_back(arg);
      }
    return (true);
  }

  std::ostream& operator<<(std::ostream& s, const Command& c)
  {
    s << c.getName();

    for (auto p : c.getArgs())
      {
	s << " " << p;
      }
    return (s);
  }

}
