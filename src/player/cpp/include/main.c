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

#include <string>
#include <iostream>
#include "CircularBuffer.h"

using namespace SpDj;

int main()
{
    CircularBuffer<char> b;
    std::string str = "0123456789";
    size_t len;
    char buf[4096];


    char c = '0';
    len = 1;
    for(int i = 0;  i < 10000; i++) {
	if (rand() % 2)
	    b.write(str.begin(), str.end());
	else
	    {
		len = b.read(buf, 2);
		buf[len] = 0;
		if (len == 0)
		    continue;
		if (buf[0] != c)
		    std::cout << "FAILED" << std::endl;
		c++;
		if (c > '9')
		    c = '0';
		if (buf[1] != c)
		    std::cout << "FAILED" << std::endl;
		c++;
		if (c > '9')
		    c = '0';
		std::cout << "TESOK" << std::endl;
	    }
    }



	std::cout << "OK" << std::endl;


    return (0);
}
