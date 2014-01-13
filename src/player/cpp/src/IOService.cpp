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

#include <event2/thread.h>
#include "IOService.h"


namespace SpDj
{
    static IOService g_ioservice;

    IOService::IOService() {
	if (evthread_use_pthreads() == -1)
	    throw std::runtime_error("Can't init IOService thread support");
	_base = event_base_new();

    }
    IOService::~IOService() {
	event_base_free(_base);
    }

    int IOService::run() {
	return event_base_loop(g_ioservice._base, 0);
    }

    int IOService::stop() {
	return event_base_loopexit(g_ioservice._base, NULL);
    }

    bool IOService::addTimer(long long millisecond, const std::function<void ()>&f) {
	struct timeval timeout = {millisecond / 1000, millisecond % 1000};
	return g_ioservice.addEvent(-1, &timeout, 0, f);
    }

    bool IOService::addTask(const std::function<void ()>&f) {
	return g_ioservice.addTimer(0, f);
    }


    bool IOService::watchFdRead(int fd, const std::function<void ()>&f) {
	return g_ioservice.addEvent(fd, NULL, EV_READ, f);
    }

    bool IOService::addEvent(int fd, struct timeval* timeout, short flag, const std::function<void ()>&f)
    {
	struct event** event;

	event = new struct event*;
	auto cb = new std::function<void ()>([this, event, f] () {
		f();
		event_free(*event);
		delete event;
	    });
	*event = event_new(g_ioservice._base, fd, flag, IOService::eventCallback, cb);
	event_add(*event, timeout);
	return true;
    }

    void IOService::eventCallback(evutil_socket_t , short , void *arg) {
	std::function<void()>* f = reinterpret_cast<std::function<void()>* >(arg);
	(*f)();
	delete f;
    }
}
