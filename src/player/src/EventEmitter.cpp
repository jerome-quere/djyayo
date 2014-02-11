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

#include "EventEmitter.h"

namespace SpDj
{
    EventEmitter::Hook::Hook(IHook* h) {
	_hook = std::shared_ptr<IHook>(h);
    }

    EventEmitter::HookTemplate0::HookTemplate0(const std::function<bool ()>& f) {
	_f = f;
    }

    bool EventEmitter::HookTemplate0::operator()() const {
	return _f();
    }

    bool EventEmitter::Hook::operator()() const {
	auto h = dynamic_cast<HookTemplate0*>(_hook.get());
	if (h != NULL)
	    return h->operator()();
	throw std::invalid_argument("Invalid argument on emit");
    }


    void EventEmitter::on(const std::string& s, const std::function<bool ()>& f) {
	_hooks.insert(std::pair<std::string, Hook>(s, Hook(new HookTemplate0(f))));
    }

    void EventEmitter::on(const std::string&s , const std::function<void ()>& h) {
	std::function<bool ()> f([h] () {h(); return true;});
	_hooks.insert(std::pair<std::string, Hook>(s, Hook(new HookTemplate0(f))));
    }

    void EventEmitter::emit(const std::string& s) const {
	auto it = _hooks.find(s);
	while (it != _hooks.end() && it->first == s)
	    {
		auto f = std::bind(it->second);
		IOService::addTask([this, it, f] () mutable {
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
