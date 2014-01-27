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

#include <QThread>
#include <QTimer>
#include <QSignalMapper>
#include "IOService.h"

#include <iostream>

namespace SpDj
{
    static IOService g_ioservice;


    IOService::Event::Event() {
	_timer = nullptr;
    }


    IOService::Event::Event(QTimer* timer) {
	_timer = timer;
    }

    void IOService::Event::cancel() {
	if (_timer) {
	    g_ioservice._removeTimer(_timer);
	    _timer = nullptr;
	}
    }


    IOService::IOService() :
	_argc(1),
	_argv(NULL),
	_app(_argc, _argv)
    {
	connect(this, &IOService::_addTask, this, &IOService::_onAddTask, Qt::QueuedConnection);
    }

    IOService::~IOService() {
    }

    int IOService::run() {
	return g_ioservice._app.exec();
    }

    void IOService::stop() {
	return g_ioservice._app.exit(0);
    }


    IOService::Event IOService::addTimer(long long millisecond, const std::function<void ()>&f) {
	if (QThread::currentThread() != QCoreApplication::instance()->thread())
	    throw std::runtime_error("NO THE GOOGD THREAD");
	QTimer* t = new QTimer(&g_ioservice);
	connect(t, &QTimer::timeout, &g_ioservice, &IOService::_onTimeout, Qt::QueuedConnection);
	t->start(millisecond);
	g_ioservice._cbs[t] = f;
	return Event(t);
    }

    void IOService::addTask(const std::function<void ()>&f) {
	auto t = new std::function<void ()>(f);
	g_ioservice._addTask(t);
    }

    void IOService::_onAddTask(std::function<void ()>*f) {
	(*f)();
	delete f;
    }

    void IOService::_onTimeout() {
	auto it = _cbs.find(sender());
	if (it != _cbs.end()) {
	    it->second();
	    _removeTimer(it->first);
	}


    }

    void IOService::_removeTimer(QObject* timer) {
	auto it = _cbs.find(timer);
	if (it != _cbs.end()) {
	    _cbs.erase(it);
	    delete timer;
	}
    }
}
