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

namespace SpDj
{
    template <typename T>
    CircularBuffer<T>::CircularBuffer() : CircularBuffer(0) {
    }

    template <typename T>
    CircularBuffer<T>::CircularBuffer(size_t minimumSize) {
	_buffer = NULL;
	_read = NULL;
	_write = NULL;
	resize(minimumSize);
    }

    template <typename T>
    CircularBuffer<T>::~CircularBuffer() {
	delete [] _buffer;
    }

    template <typename T>
    template <typename I>
    void CircularBuffer<T>::write(I begin, I end) {
	reserve(size() + (end - begin));
	while (begin != end) {
	    *_write = *(begin++);
	    if (++_write == _buffer + _size)
		_write = _buffer;
	}
    }

    template <typename T>
    template <typename I>
    size_t CircularBuffer<T>::read(I it, size_t len) {
	size_t l = copy(it, len);
	_read += l;
	if (_read >= _buffer + _size)
	    _read = _buffer + (_read - (_buffer + _size));
	if (size() < (_size - 1) / 4)
	    resize(_size / 2 + 1);
	return l;
    }

    template <typename T>
    size_t CircularBuffer<T>::size() {
	if (_buffer == NULL || _read == _write)
	    return 0;
	if (_read < _write)
	    return _write - _read;
	return (_buffer + _size) - _read + _write - _buffer;
    }

    template <typename T>
    CircularBuffer<T>::CircularBuffer(const CircularBuffer&) {
	//DELETED
    }

    template <typename T>
    size_t CircularBuffer<T>::resize(size_t newSize) {
      T* newBuffer = NULL;
      size_t size = 0;

      newSize = std::min(_minimumSize, newSize);
      if (newSize)
	{
	  newBuffer = new T [newSize]();
	  size = copy(newBuffer, newSize);
	}
      _read = newBuffer;
      _write = newBuffer + size;
      _size = newSize;
      delete _buffer;
      _buffer = newBuffer;
      return newSize;
    }

    template <typename T>
    size_t CircularBuffer<T>::reserve(size_t size) {
	size_t nsize = 2;

	while (nsize <= size) {
	    nsize *= 2;
	}
	if (nsize >= _size) {
	    resize(nsize + 1);
	}
	return _size;
    }

    template <typename T>
    void CircularBuffer<T>::clear() {
	_read = _buffer;
	_write = _buffer;
    }


    template <typename T>
    template <typename I>
    size_t CircularBuffer<T>::copy(I it, size_t len) {
	size_t size = 0;
	auto read = _read;

	while (_buffer && size < len) {
	    if (read == _buffer + _size)
		read = _buffer;
	    if (read == _write)
		break;
	    *(it++) = *(read++);
	    size++;
	}
	return size;
    }

}
