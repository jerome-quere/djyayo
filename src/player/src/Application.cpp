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

    void Application::execCommand() {
	static std::map<std::string, When::Promise<Command> (Application::*)(const Command&)> actions;


	if (actions.size() == 0) {
	    actions.insert(std::make_pair("hello", &Application::onCommandHello));
	    actions.insert(std::make_pair("search", &Application::onCommandSearch));
	    actions.insert(std::make_pair("play", &Application::onCommandPlay));
	    actions.insert(std::make_pair("stop", &Application::onCommandStop));
	    actions.insert(std::make_pair("lookup", &Application::onCommandLookup));
	}

	while (_commands.size())
	    {
		Command c = _commands.front();
		auto it = actions.find(c.name());

		if (it == actions.end()) {
		    _communicator.send(Command("error", "Unknow command"));
		    _commands.pop();
		    continue;
		}
		auto promise = (this->*(it->second))(c);
		promise.then( [this] (const Command& c) {
			_communicator.send(c);
			_commands.pop();
			execCommand();
		    });
		promise.otherwise( [this] (const std::string& error) {
			_communicator.send(Command("error", error));
			_commands.pop();
			execCommand();
		    });
		break;
	    }
    }


    void Application::onCommand(const Command& c) {

	if (c.name() == "ping")
	    return onCommandPing(c);

	if (c.name() == "error")
	    return onCommandError(c);

	_commands.push(c);
	if (_commands.size() == 1)
	    execCommand();
    }

    void Application::onEndOfTrack()
    {
	std::cout << "endOfTrack" << std::endl;
	_communicator.send(Command("endOfTrack"));
    }

    When::Promise<Command> Application::onCommandHello(const Command&) {
	auto d = When::defer<Command>();
	d.resolve(Command("joinRoom", Config::getRoomName()));
	return d.promise();
    }

    void Application::onCommandError(const Command& c) {
	std::cout << "The server send an error: " << c.param() << std::endl;
	this->stop();
    }


    void Application::onCommandPing(const Command& c) {
	_communicator.send(Command("pong", c.param()));
    }

    When::Promise<Command> Application::onCommandSearch(const Command& c) {
	std::cout << c.toString() << std::endl;
	return _spotify.search(c.param()).then( [this] (SearchResult res) {
		return Command("success", res.toJson());
	    });
    }

    When::Promise<Command> Application::onCommandPlay(const Command& c) {
	std::cout << c.toString() << std::endl;
	return _spotify.play(c.param()).then([this] (bool) {
		return Command("success", "{}");
	    });
    }

    When::Promise<Command> Application::onCommandStop(const Command& c) {
	std::cout << c.toString() << std::endl;
	auto d = When::defer<Command>();
	d.resolve(Command("success", "{}"));
	_spotify.stop();
	return d.promise();
    }

    When::Promise<Command> Application::onCommandLookup(const Command& c) {
	std::cout << c.toString() << std::endl;
	return _spotify.lookupTrack(c.param()).then([this] (const Track& track) {
		return Command("success", track.toJson());
	    });
    }

}
