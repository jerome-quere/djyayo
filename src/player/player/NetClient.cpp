#include <iostream>

#include <QObject>

#include "NetClient.hpp"

namespace Spdj
{

  NetClient::NetClient()
 {
   QObject::connect(&_socket, &QIODevice::readyRead, this, &NetClient::onReadyRead);
   QObject::connect(&_socket, &QAbstractSocket::connected, this, &NetClient::onConnect);
   QObject::connect(&_socket, &QAbstractSocket::disconnected, this, &NetClient::onDisconnect);
   QObject::connect(&_socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onError(QAbstractSocket::SocketError)));
 }

  Df::Promise<bool> NetClient::connect(const std::string& host, int port)
  {
    Df::Deferred<bool> d;

    _resolver = d.resolver();
    _socket.connectToHost(host.c_str(), port);
    return d.promise();
  }

  void NetClient::write(const std::string& str)
  {
    std::string s;

    s = str + "\n";
    _socket.write(s.c_str(), s.size());
  }

  void NetClient::onConnect()
  {
     if (_resolver)
       {
	 _resolver.resolve(true);
	 _resolver.clear();
       }
  }

  void NetClient::onDisconnect()
  {
    std::cout << "ON DISCONNECTION" << std::endl;
  }

  void NetClient::onError(QAbstractSocket::SocketError)
  {
    std::cout << "ON ERRROR ["  <<  _socket.errorString().toStdString() << "]"<< std::endl;
    if (_resolver)
      {
	_resolver.reject(_socket.errorString().toStdString());
	_resolver.clear();
      }
  }

  void NetClient::onReadyRead()
  {
    char buf[4096] = {0};
    size_t idx;

    _socket.read(buf, 4095);
    _buffer += std::string(buf);
    std::cout << _buffer << std::endl;
    if ((idx = _buffer.find_first_of('\n')) != std::string::npos)
      {
	auto line = _buffer.substr(0, idx);
	_buffer = _buffer.substr(idx + 1);
	emit commandReceived(line);
      }
  }

}
