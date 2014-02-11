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

#ifndef _WHEN_CORE_H_
#define _WHEN_CORE_H_

#include <list>

namespace When
{
    template <typename T>
    class Core
    {
	enum Status {
	    PENDING,
	    RESOLVED,
	    REJECTED,
	};

    public:
	Core();
	template <typename R>
	Promise<R> then(const std::function<R (const T&)> &f);

	template <typename R>
	Promise<R> then(const std::function<Promise<R> (const T&)> &f);

	Promise<bool> then(const std::function<void (const T&)> &f);

	void otherwise(const std::function<void (const std::string&)> &f);

	void finally(const std::function<void ()>& f);

	void success(const std::function<void ()>& f);
	void error(const std::function<void ()>& f);

	void resolve(const T& value);
	void resolve(const Promise<T>& promise);

	void reject(const std::string& err);

	std::shared_ptr<Core<T> > lock();

	bool isPending();

    private:

	std::list<std::function<void ()> > _cbs;
	Status _status;
	T _value;
	std::string _error;

	std::weak_ptr<Core<T> > _self;
    };
}

#include "Core.hpp"

#endif
