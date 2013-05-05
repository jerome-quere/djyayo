#include <iostream>
#include <sstream>

#include "Communicator.hpp"

namespace Spdj
{
  Communicator::Communicator()
  {
    QObject::connect(&_client, &NetClient::commandReceived, this, &Communicator::onCommandReceived);
  }

  Df::Promise<bool> Communicator::connect(const std::string& host,  int port)
  {
    return _client.connect(host, port);
  }

  void Communicator::send(const Command& c)
  {
    std::stringstream s;

    s << c;
    _client.write(s.str());
  }

  void Communicator::onCommandReceived(const std::string& cmd)
  {
    Command c;

    c.parse(cmd);
    std::cout << "Command Recieved [" << cmd << "]" << std::endl; 
    emit newCommand(c);
  }

}
