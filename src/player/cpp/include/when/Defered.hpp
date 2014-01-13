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

namespace When
{
    /*
     * Start _Defered Implementation
     */
    template <typename ...Args>
    void _Defered<Args...>::resolve(Args... args) {
	_promise.resolve(args...);
    }

    template <typename ...Args>
    void _Defered<Args...>::reject(const std::string& error) {
	_promise.reject(error);
    }

    template <typename ...Args>
    _Promise<Args...>* _Defered<Args...>::promise() {
	return &_promise;
    }

    template <typename ...Args>
    _Defered<Args...>::_Defered()
    {
    }


    /*
     * Start Defered Implementation
     */
    template <typename ...Args>
    Defered<Args...>::Defered() {}

    template <typename ...Args>
    Promise<Args...> Defered<Args...>::promise() {
	return Promise<Args...>(_defered);
    }

    template <typename ...Args>
    void Defered<Args...>::resolve(Args... args) {
	return _defered->resolve(args...);
    }

    template <typename ...Args>
    void Defered<Args...>::resolve(Promise<Args...> promise) {
	Defered<Args...> d = *this;
	promise.then( [d] (Args... args) -> void {
		auto d2 = d;
		d2.resolve(args...);
	    });

	promise.otherwise( [d] (const std::string& error) {
		auto d2 = d;
		d2.reject(error);
	    });
    }

    template <typename ...Args>
    void Defered<Args...>::reject(const std::string& error) {
	return _defered->reject(error);
    }

    template <typename ...Args>
    Defered<Args...>::Defered(_Defered<Args...>* defer) :
	_defered(defer)
    {
    }


}
