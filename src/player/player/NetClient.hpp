#ifndef _SPDJ_NET_CLIENT_HPP_
#define _SPDJ_NET_CLIENT_HPP_

#include <QObject>
#include <QTcpSocket>

#include "Deferred.hpp"

namespace Spdj
{
  class NetClient : public QObject
  {
    Q_OBJECT;

  public:
    NetClient();

    Df::Promise<bool> connect(const std::string&, int);
    void	      write(const std::string&);

  signals:
    void commandReceived(const std::string&);

  private slots:

    void onConnect();
    void onDisconnect();
    void onError(QAbstractSocket::SocketError);
    void onReadyRead();

  private:
    QTcpSocket	       _socket;
    Df::Resolver<bool> _resolver;
    std::string	       _buffer;
  };
}


#endif /* _SPDJ_NET_CLIENT_HPP_ */
