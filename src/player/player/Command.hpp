#ifndef _SPDJ_COMMAND_HPP_
#define _SPDJ_COMMAND_HPP_

#include <cstddef>
#include <string>
#include <vector>

namespace Spdj
{

  class Command
  {
  public:

    Command();
    ~Command();
    Command(const Command&);
    Command& operator=(const Command&);

    const std::string& getName() const;
    const std::vector<std::string>& getArgs() const;

    void setName(const std::string&);
    bool parse(const std::string&);

  private:

    std::string _name;
    std::vector<std::string> _args;

  };

  std::ostream& operator<<(std::ostream&, const Command&);

}
#endif /* _SPDJ_COMMAND_HPP_ */
