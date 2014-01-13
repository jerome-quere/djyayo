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

#include <iostream>

namespace SpDj
{
    Communicator::Communicator() :
	_stream(0)
    {
	_stream.on("data", [this] (const std::vector<int8_t>& v) -> void { onData(v); });
    }


    bool Communicator::send(const Command& c) {
	std::cout << c.toString() << std::endl;
	return true;
    }


    bool Communicator::start() {
	return _stream.start();
    }

    bool Communicator::isCommandReady() {
	return std::find(_buffer.begin(), _buffer.end(), '\n') != _buffer.end();
    }

    std::string Communicator::getLine() {
	auto it = std::find(_buffer.begin(), _buffer.end(), '\n');
	if (it == _buffer.end())
	    return "";
	char str [it - _buffer.begin() + 1];
	std::copy(_buffer.begin(), it, str);
	str[it - _buffer.begin()] = '\0';
	_buffer.erase(_buffer.begin(), it + 1);
	return std::string(str);
    }

    void Communicator::onData(const std::vector<int8_t>& data) {
	std::string line;

	_buffer.insert(_buffer.begin(), data.begin(), data.end());
	while (isCommandReady()) {
	    line = getLine();
	    emit("command", Command::fromString(line));
	}
    }
}
