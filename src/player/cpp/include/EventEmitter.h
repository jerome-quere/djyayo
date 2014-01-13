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

#ifndef _SPDJ_EVENTEMMITER_H_
#define _SPDJ_EVENTEMMITER_H_

#include <functional>
#include <map>
#include <memory>

namespace SpDj
{
    class EventEmitter
    {
	template <typename T>
	struct LambdaResolver : public LambdaResolver<decltype(&T::operator())> {};

	template <typename R, typename C, typename ...A>
	struct LambdaResolver<R (C::*)(A...) const>
	{
	    typedef R retrunType;
	    typedef std::function<R(const A& ...)> function;
	};


	struct IHook {
	public:
	    virtual ~IHook() {};
	};

	template <typename ...Args>
	struct HookTemplate : public IHook
	{
	    HookTemplate(const std::function<bool (const Args& ...)>&);
	    bool operator()(const Args& ...args) const;
	    std::function<bool (const Args& ...)> _f;
	};

	struct Hook
	{
	    Hook(IHook*);

	    template <typename ...Args>
	    bool operator()(const Args& ...) const;
	    std::shared_ptr<IHook>_hook;
	};


    public:
	template <typename T>
	void on(const std::string&, const T&);

	template <typename ...Args>
	void on(const std::string&, const std::function<bool (const Args&...)>&);

	template <typename ...Args>
	void on(const std::string&, const std::function<void (const Args&...)>&);

	template <typename ...A>
	void emit(const std::string&, const A& ... args) const;

    private:
	mutable std::multimap<std::string, Hook> _hooks;
    };
}

#include "EventEmitter.hpp"


#endif
