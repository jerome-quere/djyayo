#ifndef _SPDJ_CONFIG_HPP_
#define _SPDJ_CONFIG_HPP_

#include <string>

namespace Spdj
{

  class Config
  {
  public:
    Config(int, char**);

    const std::string& getLogin() const;
    const std::string& getPassword() const;
    const std::string& getHostname() const;
    int getPort() const;

  private:

    std::string _login;
    std::string _password;
    std::string _hostname;
    int	      _port;
  };

}
#endif
