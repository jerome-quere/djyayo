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

#include <algorithm>

#include "Command.h"
#include "Communicator.h"
#include "Config.h"

#include <iostream>

namespace SpDj
{
    Communicator::Communicator()
    {
	_state = NONE;
	_socket = nullptr;
    }

    Communicator::~Communicator() {
	delete _socket;
    }

    bool Communicator::send(const Command& c) {
	std::string s = c.toString() + "\n";
	if (_state != CONNECTED)
	    return false;
	_socket->write(s.begin(), s.end());
	return true;
    }

    When::Promise<bool> Communicator::start() {
	_state = CONNECTING;
	_socket = new Socket();
	_socket->on("data", [this] (const std::vector<int8_t>& v) -> void { onData(v); });
	_socket->on("end", [this] () -> void { onEnd(); });
	_socket->on("timeout", [this] () -> void { onTimeout(); });

	return _socket->connect(Config::getHost(), Config::getPort()).then([this] (bool) -> bool {
		_state = CONNECTED;
		_socket->setTimeout(1000 * 45);
		std::cout << "Connection to server success" << std::endl;
		return true;
	    });
    }

    bool Communicator::isCommandReady() {
	return std::find(_buffer.begin(), _buffer.end(), '\n') != _buffer.end();
    }

    std::string Communicator::getLine() {
	auto it = std::find(_buffer.begin(), _buffer.end(), '\n');
	if (it == _buffer.end())
	    return "";
	std::string str(_buffer.begin(), it);
	_buffer.erase(_buffer.begin(), it + 1);
	return str;
    }

    void Communicator::onData(const std::vector<int8_t>& data) {
	std::string line;

	_buffer.insert(_buffer.begin(), data.begin(), data.end());
	while (isCommandReady()) {
	    line = getLine();
	    emit("command", Command::fromString(line));
	}
    }

    void Communicator::restart() {
	_state = CONNECTING;
	delete _socket;
	_socket = nullptr;
	start().otherwise([this] (const std::string& err) {
		std::cerr << err << ": Try again in few second" <<std::endl;
		IOService::addTimer(20 * 1000, [this] () { restart();});
	    });
    }

    void Communicator::onEnd() {
	std::cout << "The connection have been closed" << std::endl;
	restart();
    }

    void Communicator::onTimeout() {
	std::cout << "The connection timout" << std::endl;
	restart();
    }
}
