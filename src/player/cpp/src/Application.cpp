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

namespace SpDj
{
    Application::Application() {
	_communicator.on("command", [this] (const Command&c) { onCommand(c);});
	_spotify.on("endOfTrack", [this] () {onEndOfTrack();});
    }

    int Application::run() {

	_spotify.login("yayo56", "epitech42").then([this] (bool) {
		_communicator.start();
		_communicator.send(Command("success"));
		});
	return IOService::run();
    }

    void Application::onCommand(const Command& c) {
	if (c.name() == "exit")
	    IOService::stop();

	if (c.name() == "search") {
	    auto p = _spotify.search(c.param());
	    p.then( [this] (const SearchResult& res) {
		    Command c("searchresult", res.toJson());
		    _communicator.send(c);
		});
	    p.otherwise( [this] (const std::string& error) {
		    _communicator.send(Command("error", error));
		});
	}
	if (c.name() == "play") {
	    auto p = _spotify.play(c.param());
	    p.then([this] (bool) -> void {
		    _communicator.send(Command("success"));
		});
	    p.otherwise([this] (const std::string& error) {
		    _communicator.send(Command("error", error));
		});
	}
    }

    void Application::onEndOfTrack()
    {
	_communicator.send(Command("endOfTrack"));
    }

}
