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

#ifndef _SPDJ_SOCKET_H_
#define _SPDJ_SOCKET_H_

#include <vector>

#include <QObject>
#include <QAbstractSocket>

#include "IOService.h"
#include "EventEmitter.h"
#include "when/When.h"

class QTcpSocket;

namespace SpDj
{
    class Socket : public QObject, public EventEmitter
    {
	Q_OBJECT;

    public:
	Socket();
	~Socket();
	When::Promise<bool> connect(const std::string& host, int port);

	template <typename It>
	void write(It first, It end);
	void close();

	void setTimeout(long long milisecond);

    private:

	void _watchTimeout();

    private Q_SLOTS:
	void _onReadReady();
	void _onConnected();
	void _onDisconnected();
	void onError(QAbstractSocket::SocketError socketError);
	void _onTimeout();

    private:
	When::Deferred<bool> _connectDefer;
	QTcpSocket*	_socket;
	bool		_activity;
	long long	_timeout;
	IOService::Event _timeoutEvent;
    };
}

#include "Socket.hpp"

#endif
