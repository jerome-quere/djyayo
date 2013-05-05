#ifndef _SPDJ_COMMUNICATOR_HPP_
#define _SPDJ_COMMUNICATOR_HPP_

#include <QObject>

#include "Deferred.hpp"

#include "Command.hpp"
#include "NetClient.hpp"

namespace Spdj
{
  class Communicator : public QObject
  {
    Q_OBJECT;

  public:
    Communicator();

    Df::Promise<bool> connect(const std::string&, int);
    void send(const Command&);

  signals:
    void newCommand(const Command&);

  private slots:

    void onCommandReceived(const std::string&);

  private:
    NetClient	_client;
  };

}

#endif
