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

#ifndef _WHEN_LAMBDA_RESOLVER_H_
#define _WHEN_LAMBDA_RESOLVER_H_

#include "Definition.h"

namespace When
{
    template <typename R>
    struct LambdaResolver2 {
	typedef R return_type;
	typedef Promise<R> promise_type;
    };

    template <typename R>
    struct LambdaResolver2<Promise<R> > {
	typedef Promise<R> return_type;
	typedef Promise<R> promise_type;
    };

    template <>
    struct LambdaResolver2<void> {
	typedef void return_type;
	typedef Promise<bool> promise_type;
    };

    template <typename T, typename A1>
    struct LambdaResolver : public LambdaResolver2<typename std::result_of<T(const A1&)>::type> {
    };
}


#endif
