#ifndef _SPDJ_APPLICATION_HPP_
#define _SPDJ_APPLICATION_HPP_

#include <string>

#include <QCoreApplication>

#include "Communicator.hpp"
#include "Config.hpp"
#include "Spotify.hpp"

namespace Spdj
{
  class Application : public QObject
  {
    Q_OBJECT;

  public:

    Application(const Config&);
    ~Application();

    int run();
    void stop();

  private slots:

    void onNewCommand(const Command&);
    void onEndOfTrack();

  private:

    void onPlayCommand(const Command&);
    void fatalError(const std::string& e);


    Config	 _config;
    Communicator _communicator;
    Spotify	 _spotify;

    QCoreApplication _qtApp;
  };
}

#endif
