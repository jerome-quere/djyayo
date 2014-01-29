/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jerome Quere <contact@jeromequere.com>
 *
 * Permission is hereby granted, free  of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction,  including without limitation the rights
 * to use,  copy,  modify,  merge, publish,  distribute, sublicense, and/or sell
 * copies  of  the  Software,  and  to  permit  persons  to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The  above  copyright  notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY  OF ANY KIND, EXPRESS OR
 * IMPLIED,  INCLUDING BUT NOT LIMITED  TO THE  WARRANTIES  OF  MERCHANTABILITY,
 * FITNESS  FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR  ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT  OF  OR  IN  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "Application.h"
#include "Config.h"


#include <iostream>
namespace SpDj
{
    Application::Application() {
	_communicator.on("command", [this] (const Command&c) { onCommand(c);});
	_spotify.on("endOfTrack", [this] () {onEndOfTrack();});
    }

    int Application::run() {
	auto p = _spotify.login(Config::getLogin(), Config::getPassword()).then([this] (bool) {
		return _communicator.start();
		});
	p.otherwise([this] (const std::string& err) {
		std::cerr << err << std::endl;
		stop();
	    });
	return IOService::run();
    }

    void Application::stop() {
	IOService::stop();
    }

    void Application::onCommand(const Command& c) {

	static std::map<std::string, void (Application::*)(const Command&)> actions = {
	    {"exit", &Application::onCommandStop},
	    {"hello", &Application::onCommandHello},
	    {"ping", &Application::onCommandPing},
	    {"search", &Application::onCommandSearch},
	    {"play", &Application::onCommandPlay},
	    {"lookup", &Application::onCommandLookup}
	};

	auto it = actions.find(c.name());

	if (it != actions.end())
	    (this->*(it->second))(c);
	else
	    _communicator.send(Command("error", "Unknow command"));
    }

    void Application::onEndOfTrack()
    {
	std::cout << "endOfTrack" << std::endl;
	_communicator.send(Command("endOfTrack"));
    }


    void Application::onCommandStop(const Command&) {
	stop();
    }

    void Application::onCommandHello(const Command&) {
	_communicator.send(Command("joinRoom", Config::getRoomName()));
    }

    void Application::onCommandPing(const Command& c) {
	_communicator.send(Command("pong", c.param()));
    }

    void Application::onCommandSearch(const Command& c) {
	std::cout << c.toString() << std::endl;
	auto p = _spotify.search(c.param());
	p.then( [this] (SearchResult res) {
		Command c("success", res.toJson());
		_communicator.send(c);
	    });
	p.otherwise( [this] (const std::string& error) {
		_communicator.send(Command("error", error));
	    });
    }

    void Application::onCommandPlay(const Command& c) {
	std::cout << c.toString() << std::endl;
	auto p = _spotify.play(c.param());
	p.then([this] (bool) -> void {
		_communicator.send(Command("success", "{}"));
	    });
	p.otherwise([this] (const std::string& error) {
		_communicator.send(Command("error", error));
	    });
    }


    void Application::onCommandLookup(const Command& c) {
	std::cout << c.toString() << std::endl;
	auto p = _spotify.lookupTrack(c.param());
	p.then([this] (const Track& track) -> void {
		_communicator.send(Command("success", track.toJson()));
	    });
	p.otherwise([this] (const std::string& error) {
		_communicator.send(Command("error", error));
	    });
    }



}
