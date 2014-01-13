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

#include <unistd.h>
#include <functional>
#include <vector>

#include "FdStream.h"
#include "IOService.h"

#include <iostream>

namespace SpDj
{
    FdStream::FdStream(int fd) {
	_fd = fd;
    }

    bool FdStream::start() {
	connect();
	return true;
    }

    void FdStream::onReadyRead() {
	std::vector<int8_t> data;
	int8_t buf[4096];
	size_t size = 4096;

	while (size == 4096) {
	    size = ::read(_fd, buf, 4096);
	    data.insert(data.end(), buf, buf + size);
	}
	emit("data", data);
	connect();
    }

    void FdStream::connect() {
	IOService::watchFdRead(_fd, std::bind(&FdStream::onReadyRead, this));
    }

}
