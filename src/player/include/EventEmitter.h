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

	template <typename R, typename C>
	struct LambdaResolver<R (C::*)() const>
	{
	    typedef R retrunType;
	    typedef std::function<R()> function;
	};

	template <typename R, typename C, typename A1>
	struct LambdaResolver<R (C::*)(A1) const>
	{
	    typedef R retrunType;
	    typedef std::function<R(const A1&)> function;
	};


	struct IHook {
	public:
	    virtual ~IHook() {};
	};


	struct HookTemplate0 : public IHook
	{
	    HookTemplate0(const std::function<bool ()>&);
	    bool operator()() const;
	    std::function<bool ()> _f;
	};

	template <typename A1>
	struct HookTemplate1 : public IHook
	{
	    HookTemplate1(const std::function<bool (const A1&)>&);
	    bool operator()(const A1&) const;
	    std::function<bool (const A1&)> _f;
	};

	struct Hook
	{
	    Hook(IHook*);

	    bool operator()() const;

	    template <typename A1>
	    bool operator()(const A1&) const;
	    std::shared_ptr<IHook>_hook;
	};


    public:

	void on(const std::string&, const std::function<bool ()>&);
	void on(const std::string&, const std::function<void ()>&);

	template <typename T>
	void on(const std::string&, const T&);

	template <typename A1>
	void on(const std::string&, const std::function<bool (const A1&)>&);

	template <typename A1>
	void on(const std::string&, const std::function<void (const A1&)>&);

	template <typename A1>
	void emit(const std::string&, const A1&) const;

	void emit(const std::string&) const;

    private:
	mutable std::multimap<std::string, Hook> _hooks;
    };
}

#include "EventEmitter.hpp"


#endif
