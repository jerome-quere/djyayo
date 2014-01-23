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

#ifndef _SPDJ_IOSERVICE_H_
#define _SPDJ_IOSERVICE_H_


#include <event2/event.h>
#include <functional>
#include <memory>
#include <set>

namespace SpDj
{
    class IOService
    {
    public:

	class Event
	{
	public:
	    Event();
	    void cancel();

	private:
	    Event(event_base* base, int fd, struct timeval* timeout, short flag, const std::function<void ()>&f);

	    friend class IOService;
	    std::shared_ptr<bool>	_active;
	    std::weak_ptr<event*>	_event;
	};

	IOService();
	~IOService();

	static int run();
	static int stop();
	static Event addTimer(long long millisecond, const std::function<void ()>&f);
	static Event addTask(const std::function<void ()>&f);
	static Event watchFdRead(int fd, const std::function<void (int)>&f);
	static Event watchFdWrite(int fd, const std::function<void (int)>&f);

    private:

        Event addEvent(int fd, struct timeval*, short flag, const std::function<void ()>&f);
	static void eventCallback(evutil_socket_t , short , void *arg);
	struct event_base*_base;
    };
}

#endif
