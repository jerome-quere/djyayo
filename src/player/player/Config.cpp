#include "options.hpp"

#include "Config.hpp"

namespace Spdj
{

  Config::Config(int argc, char** argv) :
    _port(0)
  {
    options::add("-h", "--hostname", _hostname);
    options::add("-p", "--port", _port, options::none);
    options::add("-l", "--login", _login, options::none);
    options::add("", "--password", _password, options::none);
    options::parse(argc, argv);
  }

  const std::string& Config::getLogin() const
  {
    return _login;
  }

  const std::string& Config::getPassword() const
  {
    return _password;
  }

  const std::string& Config::getHostname() const
  {
    return _hostname;
  }

  int Config::getPort() const
  {
    return _port;
  }

}
