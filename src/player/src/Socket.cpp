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

namespace SpDj
{
    Socket::Socket() {
	_connectDefer = When::defer<bool>();
        _socket = new QTcpSocket(this);
	_activity = false;
	_timeout = 0;
	QObject::connect(_socket, SIGNAL(readyRead()), this, SLOT(_onReadReady()));
	QObject::connect(_socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(onError(QAbstractSocket::SocketError)));
	QObject::connect(_socket, SIGNAL(connected()), this, SLOT(_onConnected()));
	QObject::connect(_socket, SIGNAL(disconnected()), this, SLOT(_onDisconnected()));
    }

    Socket::~Socket() {
	_timeoutEvent.cancel();
	delete _socket;
    }

    When::Promise<bool> Socket::connect(const std::string& host, int port) {
	_socket->connectToHost(QString(host.c_str()), port);
	return _connectDefer.promise();
    }

    void Socket::setTimeout(long long milisecond) {
	_timeout = milisecond;
	_watchTimeout();
    }

    void Socket::_watchTimeout() {
	_timeoutEvent = IOService::addTimer(_timeout, [this] () {
		_onTimeout();
	    });
    }

    void Socket::_onReadReady() {
	QByteArray buf = _socket->readAll();
	std::vector<int8_t> vector(buf.data(), buf.data() + buf.length());
	emit("data", vector);
	_activity = true;
    }

    void Socket::_onConnected() {
	_connectDefer.resolve(true);
    }

    void Socket::_onDisconnected() {
	emit("end");
    }

    void Socket::onError(QAbstractSocket::SocketError) {
	if (_connectDefer.promise().isPending()) {
	    _connectDefer.reject(_socket->errorString().toStdString());
	}
	else
	    emit("end");
    }

    void Socket::_onTimeout() {
	if (_activity == false)
	    emit("timeout");
	else if (_timeout)
	    _watchTimeout();
	_activity = false;
    }
}
