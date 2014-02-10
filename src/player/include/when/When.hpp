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

#include <memory>

#include "Core.h"

namespace When
{
    template <typename T>
    Deferred<T> defer()
    {
	Core<T>* core = new Core<T>();
	return Deferred<T>(core->lock());
    }

    //TODO Refactor
    template <typename It>
    Promise<bool> all(It begin, const It& end) {
	auto defer = When::defer<bool>();
	int* count = new int(1);
	bool* failed = new bool(false);

	auto onFinished = [count, failed, defer] () {
	    auto d = defer;
	    if (*failed == true)
		d.reject("Cant resolve all promise");
	    else
		d.resolve(true);
	    delete count;
	    delete failed;
	};

	while (begin != end)
	    {
		(*count)++;
		begin->success( [count, failed, onFinished] () {
			(*count)--;
			if (*count == 0)
			    onFinished();
		    });
		begin->error( [count, failed, onFinished] () {
			(*count)--;
			*failed = true;
			if (*count == 0)
			    onFinished();
		    });
		++begin;
	    }
	(*count)--;
	if (*count == 0)
	    onFinished();
	return defer.promise();
    }

}
