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

#include <list>

#include "IOService.h"

namespace SpDj
{

    template <typename ...Args>
    EventEmitter::HookTemplate<Args...>::HookTemplate(const std::function<bool (const Args& ...)>& f) {
	_f = f;
    }

    template <typename ...Args>
    bool EventEmitter::HookTemplate<Args...>::operator()(const Args& ...args) const {
	return _f(args...);
    }

    template <typename ...Args>
    bool EventEmitter::Hook::operator()(const Args& ... args) const {
	auto h = dynamic_cast<HookTemplate<Args...>*>(_hook.get());
	if (h != NULL)
	    return h->operator()(args...);
	throw std::invalid_argument("Invalid argument on emit");
    }

    template <typename T>
    void EventEmitter::on(const std::string& s, const T& h) {
	typename LambdaResolver<T>::function f(h);
	on(s, f);
    }

    template <typename ...Args>
    void EventEmitter::on(const std::string& s, const std::function<bool (const Args& ...)>& h) {
	_hooks.insert(std::pair<std::string, Hook>(s, Hook(new HookTemplate<Args...>(h))));
    }

    template <typename ...Args>
    void EventEmitter::on(const std::string& s, const std::function<void (const Args& ...)>& h) {
	std::function<bool (Args...)> f([h] (Args... args) {h(args...); return true;});
	_hooks.insert(std::pair<std::string, Hook>(s, Hook(new HookTemplate<Args...>(f))));
    }

    template <typename ...A>
    void EventEmitter::emit(const std::string& s, const A& ... args) const
    {
	auto it = _hooks.find(s);
	while (it != _hooks.end() && it->first == s)
	    {
		auto f = std::bind(it->second, args...);
		IOService::addTask([this, it, f] () {
			if (f() == false) {
			    //TODO: It is possible that this is no longuer available exemple: delete before
			    // this lamba. Maybe use a share_ptr<bool> to handle it.
			    _hooks.erase(it);
			}
		    });
		++it;
	    }
    }
}
