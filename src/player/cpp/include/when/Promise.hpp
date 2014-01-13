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

#include "Apply.hpp"
#include "LambdaResolver.h"

namespace When
{
    /*
     * Start _Promise implementation
     */
    template <typename ...Args>
    template <typename T>
    Promise<T> _Promise<Args...>::then(const std::function<T (Args...)>&f) {
	Defered<T> d = defer<T>();
	std::function<void ()> cb = std::function<void()> ([this, d, f] () {
		auto d2 = d;

		if (_status == RESOLVED) {
		    try {
			d2.resolve(apply_tuple(f, _result));
		    } catch (const std::exception& e) {
			d2.reject(e.what());
		    }
		}
		else {
		    d2.reject(_error);
		}
	    });
	addCallback(cb);
	return d.promise();
    }


    template <typename ...Args>
    Promise<bool> _Promise<Args...>::then(const std::function<void (Args...)>&f) {
	Defered<bool> d = defer<bool>();
	std::function<void ()> cb = std::function<void ()> ([this, d, f] () {
		auto d2 = d;

		if (_status == RESOLVED) {
		    try {
			apply_tuple(f, _result);
			d2.resolve(true);
		    } catch (const std::exception& e) {
			d2.reject(e.what());
		    }
		}
		else {
		    d2.reject(_error);
		}
	    });
	addCallback(cb);
	return d.promise();
    }

    template <typename ...Args>
    template <typename ...P>
    Promise<P...> _Promise<Args...>::then(const std::function<Promise<P...> (Args...)>&f) {
	Defered<P...> d = defer<P...>();
	std::function<void ()> cb = std::function<void ()> ([this, d, f] () {
		auto d2 = d;

		if (_status == RESOLVED) {
		    try {
			d2.resolve(apply_tuple(f, _result));
		    } catch (const std::exception& e) {
			d2.reject(e.what());
		    }
		}
		else {
		    d2.reject(_error);
		}
	    });
	addCallback(cb);
	return d.promise();
    }


    template <typename ...Args>
    template <typename T>
    typename LambdaResolver<T>::promiseType _Promise<Args...>::then(const T &f) {
	typedef typename LambdaResolver<T>::returnType R;
	return then(std::function<R (Args...)>(f));
    }

    template <typename ...Args>
    void _Promise<Args...>::otherwise(const std::function<void (const std::string&)>&f)
    {
	std::function<void ()> cb = std::function<void ()> ([this, f] () {
		if (_status == REJECTED)
		    f(_error);
	    });
	addCallback(cb);
    }

    template <typename ...Args>
    template <typename T>
    void _Promise<Args...>::otherwise(const T &f) {
	return otherwise(std::function<void (const std::string&)>(f));
    }



    template <typename ...Args>
    _Promise<Args...>::_Promise() {
	_status = UNRESOLVED;
    }

    template <typename ...Args>
    void _Promise<Args...>::resolve(Args... args)
    {
	if (_status != UNRESOLVED)
	    throw std::runtime_error("The Promise is aleready resolved or reject");

	_status = RESOLVED;
	_result = std::tuple<Args...>(args...);
	for (auto &cb : _callbacks) {
	    cb();
	}
    }

    template <typename ...Args>
    void _Promise<Args...>::reject(const std::string& error)
    {
	if (_status != UNRESOLVED)
	    throw std::runtime_error("The Promise is aleready resolved or reject");

	_status = REJECTED;
	_error = error;
	for (auto &cb : _callbacks) {
	    cb();
	}
    }

    template <typename ...Args>
    void _Promise<Args...>::addCallback(const std::function <void()>& cb) {
	if (_status == UNRESOLVED)
	    _callbacks.push_back(cb);
	else
	    cb();
    }


    /*
     * Start Promise implementation
     */
    template <typename ...Args>
    template <typename T>
    typename LambdaResolver<T>::promiseType Promise<Args...>::then(const T &f) {
	return _defer->promise()->then(f);
    }

    template <typename ...Args>
    template <typename T>
    void Promise<Args...>::otherwise(const T &f) {
	return _defer->promise()->otherwise(f);
    }

    template <typename ...Args>
    Promise<Args...>::Promise(std::shared_ptr<_Defered<Args...> > defer) :
	_defer(defer)
    {
    }


}
