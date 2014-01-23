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

#include "Config.h"

namespace SpDj
{
    std::string Config::_login;
    std::string Config::_password;
    std::string Config::_roomName = "defaultRoom";
    std::string Config::_host = "localhost";
    int Config::_port = 4545;


    void Config::init(int argc, char** argv) {
	for (int i = 1 ; i + 1 < argc ; i++) {
	    if (std::string(argv[i]) == "--login")
		_login = argv[++i];
	    else if (std::string(argv[i]) == "--password")
		_password = argv[++i];
	    else if (std::string(argv[i]) == "--host")
		_host = argv[++i];
	    else if (std::string(argv[i]) == "--room")
		_roomName = argv[++i];
	    else if (std::string(argv[i]) == "--port")
		_port = atoi(argv[++i]);
	}
    }


    const std::string& Config::getLogin() {
	return _login;
    }

    const std::string& Config::getPassword() {
	return _password;
    }

    const std::string& Config::getHost() {
	return _host;
    }

    const std::string& Config::getRoomName() {
	return _roomName;
    }

    int Config::getPort() {
	return _port;
    }
}
