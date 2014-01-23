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

#include <cstring>
#include <cstdio>
#include <errno.h>

#include "Socket.h"

#include <iostream>
namespace SpDj
{
    Socket::Socket() {
	_connectDefer = When::defer<bool>();
        _socket = -1;
	_activity = false;
	_timeout = 0;
    }

    Socket::~Socket() {
	close();
    }

    When::Promise<bool> Socket::connect(const std::string& host, int port) {
	int res;
	hostent* servername;
	socklen_t addr_size;
	struct sockaddr_in serveraddr;

	_socket = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
	if (_socket == -1) {
	    _connectDefer.reject(strerror(errno));
	    return _connectDefer.promise();
	}
	memset(&serveraddr, sizeof(serveraddr), 0);
	serveraddr.sin_family = AF_INET;
	serveraddr.sin_port = htons(port);
	servername = gethostbyname(host.c_str());
	serveraddr.sin_addr = *((struct in_addr *)servername->h_addr);
	addr_size = sizeof(serveraddr);

	res = ::connect(_socket, (struct sockaddr*)&serveraddr, addr_size);
	if(res < 0 && errno != EINPROGRESS) {
	    _connectDefer.reject(strerror(errno));
	    return _connectDefer.promise();
	}

	_watchConnect();
	return _connectDefer.promise();
    }

    void Socket::close() {
	if (_socket != -1) {
	    shutdown(_socket, SHUT_RDWR);
	    _socket = -1;
	}
	_timeoutEvent.cancel();
	_writeEvent.cancel();
	_readEvent.cancel();

    }

    void Socket::setTimeout(long long milisecond) {
	_timeout = milisecond;
	_watchTimeout();
    }

    void Socket::_watchConnect() {
	_writeEvent = IOService::watchFdWrite(_socket, [this] (int fd) {_onConnectReady(fd);});
    }

    void Socket::_watchRead() {
	_readEvent = IOService::watchFdRead(_socket, [this] (int fd) {_onReadReady(fd);});
    }

    void Socket::_watchWrite() {
	_writeEvent = IOService::watchFdWrite(_socket, [this] (int fd) {_onWriteReady(fd);});
    }

    void Socket::_watchTimeout() {
	_timeoutEvent = IOService::addTimer(_timeout, [this] () {_onTimeout();});
    }

    void Socket::_onReadReady(int socket) {
	size_t	len = 4096;
	char	buf[4096];
	std::vector<int8_t> vector;

	while (len == 4096) {
	    len = recv(_socket, buf, 4096, 0);
	    if (len > 0)
		vector.insert(vector.end(), buf, buf + len);
	}
	if (len == 0) {
	    close();
	    emit("end");
	    return;
	}
	emit("data", vector);
	_watchRead();
	_activity = true;
    }

    void Socket::_onWriteReady(int socket) {
	size_t len;

	len = send(_socket, &(_writeBuffer.front()), _writeBuffer.size(), 0);
	if (len != 0)
	    _writeBuffer.erase(_writeBuffer.begin(), _writeBuffer.begin() + len);
	if (_writeBuffer.size())
	    _watchWrite();
    }

    void Socket::_onConnectReady(int socket) {
	int result;
	socklen_t result_len = sizeof(result);

	if (getsockopt(_socket, SOL_SOCKET, SO_ERROR, &result, &result_len) < 0) {
	    _connectDefer.reject("Unknow error in connect");
	    return;
	}

	if (result != 0) {
	    _connectDefer.reject(strerror(result));
	    return;
	}
	_connectDefer.resolve(true);
	_watchRead();
    }

    void Socket::_onTimeout() {
	if (_activity == false)
	    emit("timeout");
	else if (_timeout)
	    _watchTimeout();
	_activity = false;
    }
}
