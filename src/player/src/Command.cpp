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

#include <sstream>

#include "Command.h"


using namespace std;

namespace SpDj
{
    Command::Command(const std::string& name) :
	_name(name)
    {
    }

    Command::Command(const std::string& name, const std::string param)
    {
	_name = name;
	_param = param;
    }

    Command Command::fromString(const std::string& cmd)
    {
	string name, param;

	auto it = cmd.find_first_of(' ');
	name = std::string(cmd, 0, it);
	param = std::string(cmd, it + 1);
	return Command(name, param);
    }

    std::string Command::toString() const
    {
	ostringstream o;

	o << _name;
	if (_param != "")
	    o << " " << _param;
	return o.str();
    }

    const std::string& Command::name() const {
	return _name;
    }

    const std::string& Command::param() const {
	return _param;
    }

}
