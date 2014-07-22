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

#ifndef _SPDJ_CIRCULARBUFFER_H_
#define _SPDJ_CIRCULARBUFFER_H_

#include <cstddef>

namespace SpDj
{
    template <typename T>
    class CircularBuffer
    {
    public:
	CircularBuffer();
	CircularBuffer(size_t minimumSize);
	~CircularBuffer();

	template <typename I>
	void write(I begin, I end);

	template <typename I>
	size_t read(I buffer, size_t len);
	size_t size();
	size_t reserve(size_t size);
	void clear();

    private:
	CircularBuffer(const CircularBuffer&);

	size_t resize(size_t newSize);

	template <typename I>
	size_t copy(I it, size_t len);


	T*	_buffer;
        size_t	_minimumSize;
	size_t	_size;
	T*	_read;
	T*	_write;
    };
}

#include "CircularBuffer.hpp"

#endif
