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

#ifndef _WHEN_CORE_HPP_
#define _WHEN_CORE_HPP_

#include <exception>

namespace When
{
    template <typename T>
    Core<T>::Core() {
	_status = PENDING;
    }

    template <typename T>
    template <typename R>
    Promise<R> Core<T>::then(const std::function<R (const T&)>& f) {
	auto defer = When::defer<R>();

	auto f2 = [this, defer, f] () mutable {
	    if (_status == RESOLVED) {
		try {
		    defer.resolve(f(_value));
		}
		catch (const std::exception& e) {
		    defer.reject(e.what());
		}
	    }
	    else {
		defer.reject(_error);
	    }
	};

	if (_status == PENDING)
	    _cbs.push_back(f2);
	else
	    f2();
	return defer.promise();;
    }

    template <typename T>
    template <typename R>
    Promise<R> Core<T>::then(const std::function<Promise<R> (const T&)> &f) {
	auto defer = When::defer<R>();
	then([f, defer] (const T& value) mutable -> void {
		try {
		    defer.resolve(f(value));
		} catch (const std::exception& e) {
		    defer.reject(e.what());
		}
	    });
	otherwise([f, defer] (const std::string& err) mutable {
		defer.reject(err);
	    });
	return defer.promise();
   }

    template <typename T>
    Promise<bool> Core<T>::then(const std::function<void (const T&)> &f) {
	return then(std::function<bool (const T&)> ([f] (const T& value) {
		    f(value);
		    return true;
		}));
    }


    template <typename T>
    void Core<T>::otherwise(const std::function<void (const std::string&)>& f) {
	auto f2 = [this, f] {
	    if (_status == REJECTED)
		f(_error);
	};


	if (_status == PENDING)
	    _cbs.push_back(f2);
	else
	    f2();
    }

    template <typename T>
    void Core<T>::finally(const std::function<void ()>& f) {
	success(f);
	error(f);
    }

    template <typename T>
    void Core<T>::success(const std::function<void ()>& f) {
	then([f] (const T&) {
		f();
	    });
    }

    template <typename T>
    void Core<T>::error(const std::function<void ()>& f) {
	otherwise([f] (const std::string&) {
		f();
	    });
    }


    template <typename T>
    void Core<T>::resolve(const T& value) {
	if (_status != PENDING)
	    throw std::runtime_error("The promise is already resolve or reject");

	_status = RESOLVED;
	_value = value;
	for (auto& f : _cbs) {
	    f();
	}
    }

    template <typename T>
    void Core<T>::resolve(const Promise<T>& promise) {
	if (_status != PENDING)
	    throw std::runtime_error("The promise is already resolve or reject");

	Promise<T> p = promise;

	Deferred<T> d(lock());
	p.then([d] (const T& value) mutable {
		d.resolve(value);
	    });
	p.otherwise([d] (const std::string& err) mutable {
		d.reject(err);
	    });
    }

    template <typename T>
    void Core<T>::reject(const std::string& err) {
	if (_status != PENDING)
	    throw std::runtime_error("The promise is already resolve or reject");

	_status = REJECTED;
	_error = err;
	for (auto& f : _cbs) {
	    f();
	}
    }

    template <typename T>
    std::shared_ptr<Core<T> > Core<T>::lock() {
	std::shared_ptr<Core<T> > shared;
	if (_self.expired())
	    {
		shared = std::shared_ptr<Core<T> >(this);
		_self = shared;
	    }
	return _self.lock();
    }


    template<typename T>
    bool Core<T>::isPending() {
	return _status == PENDING;
    }

}

#endif
