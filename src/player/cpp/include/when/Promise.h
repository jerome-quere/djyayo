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

#ifndef _WHEN_PROMISE_H_
#define _WHEN_PROMISE_H_

#include <list>
#include <functional>
#include <memory>
#include <tuple>


#include "Definition.h"
#include "LambdaResolver.h"

namespace When
{
    template <typename ...Args>
    class _Promise {

	enum Status {
	    UNRESOLVED,
	    RESOLVED,
	    REJECTED
	};

    public:

	template<typename T>
	Promise<T> then(const std::function<T (Args...)>&f);

	Promise<bool> then(const std::function<void (Args...)>&f);

	template <typename ...P>
	Promise<P...> then(const std::function<Promise<P...> (Args...)>&f);

	template<typename T>
	typename LambdaResolver<T>::promiseType then(const T &f);


	void otherwise(const std::function<void (const std::string&)>&f);

	template<typename T>
	void otherwise(const T &f);

    private:

	_Promise();
	void resolve(Args... args);
	void reject(const std::string& error);

	void addCallback(const std::function<void ()>&);

	std::list<std::function<void ()> > _callbacks;

	Status _status;
	std::tuple<Args...> _result;
	std::string _error;

	friend class _Defered<Args...>;
    };

    template <typename ...Args>
    class Promise {

    public:
	template <typename T>
	typename LambdaResolver<T>::promiseType then(const T &f);

	template <typename T>
	void otherwise(const T &f);

    private:
	Promise(std::shared_ptr<_Defered<Args...> > defer);
	std::shared_ptr<_Defered<Args...> > _defer;

	friend class Defered<Args...>;
    };

}

#include "Promise.hpp"

#endif
