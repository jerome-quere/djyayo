#include <functional>
#include <iostream>

#include "Application.hpp"

using namespace std::placeholders;

namespace Spdj
{
  int trash = 0;

  Application::Application(const Config& config) :
    _config(config),
    _qtApp(trash, NULL)
  {
    connect(&_communicator, &Communicator::newCommand, this, &Application::onNewCommand);
    connect(&_spotify, &Spotify::endOfTrack, this, &Application::onEndOfTrack);
  }

  Application::~Application()
  {
  }

  int  Application::run()
  {
    std::cout << "Application::Run" << std::endl;
    auto p = _spotify.connect(_config.getLogin(), _config.getPassword());
    auto p2 = _communicator.connect(_config.getHostname(),
				       _config.getPort());

    p.fail(std::bind(&Application::fatalError, this, _1));
    p2.fail(std::bind(&Application::fatalError, this, _1));
    p.done([] (int) {std::cout << "Spotify: Login Success" << std::endl;});
    p2.done([] (int) {std::cout << "Connetion  Success" << std::endl;});
    return _qtApp.exec();
  }

  void Application::stop()
  {
    _qtApp.quit();
  }

  void Application::onNewCommand(const Command& c)
  {
    std::map<std::string, std::function<void (Command)> > actions;

    actions["play"] = std::bind(&Application::onPlayCommand, this, _1);

    auto it = actions.find(c.getName());
    if (it != actions.end())
      it->second(c);
  }

  void Application::onEndOfTrack()
  {
    Command c;

    c.setName("endoftrack");
    _communicator.send(c);
  }

  void Application::onPlayCommand(const Command& c)
  {
    std::string url;

    if (!c.getArgs().empty())
      _spotify.play(c.getArgs()[0]);
  }

  void Application::fatalError(const std::string& e)
  {
    std::cout << "ERROR: " << e << std::endl;
    _qtApp.exit(1);
  }

}
