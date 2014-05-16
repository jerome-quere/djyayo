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

#include <QCoreApplication>
#include <QMetaType>
#include <QThread>
#include <QTimer>
#include <QSignalMapper>
#include "IOService.h"

#include <iostream>

namespace SpDj
{
    static IOService* g_ioservice = NULL;

    static IOService& getIOService() {
	if (g_ioservice == NULL)
	    g_ioservice = new IOService();
	return *g_ioservice;
    }


    IOService::Event::Event() {
	_timer = nullptr;
    }


    IOService::Event::Event(QTimer* timer) {
	_timer = timer;
    }

    void IOService::Event::cancel() {
	if (_timer) {
	    getIOService()._removeTimer(_timer);
	    _timer = nullptr;
	}
    }


    IOService::IOService()
    {
      qRegisterMetaType<Task*>("Task*");
      connect(this, SIGNAL(_addTask(Task*)), this, SLOT(_onAddTask(Task*)), Qt::QueuedConnection);
    }

    IOService::~IOService() {
    }

    int IOService::run() {
	return QCoreApplication::instance()->exec();
    }

    void IOService::stop() {
	return QCoreApplication::instance()->exit(0);
    }


    IOService::Event IOService::addTimer(long long millisecond, const std::function<void ()>&f) {
	if (QThread::currentThread() != QCoreApplication::instance()->thread())
	    throw std::runtime_error("NO THE GOOGD THREAD");
	QTimer* t = new QTimer(&getIOService());
	connect(t, SIGNAL(timeout()), &getIOService(), SLOT(_onTimeout()), Qt::QueuedConnection);
	t->start(millisecond);
	getIOService()._cbs[t] = f;
	return Event(t);
    }

    void IOService::addTask(const std::function<void ()>&f) {
	auto t = new std::function<void ()>(f);
	getIOService()._addTask(t);
    }

    void IOService::_onAddTask(Task *f) {
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
