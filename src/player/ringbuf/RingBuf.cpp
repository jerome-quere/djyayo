/*
 * Copyright 2012 Jerome Quere < contact@jeromequere.com >.
 *
 * This file is part of SpotifyDj.
 *
 * SpotifyDj is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SpotifyDj is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SpotifyDj.If not, see <http://www.gnu.org/licenses/>.
 */

#include <algorithm>
#include <iostream>

#include "RingBuf.hpp"

namespace Spdj
{
  RingBuf::RingBuf() :
    _buf(NULL),
    _size(0),
    _read(0),
    _write(0)
  {
  }

  RingBuf::~RingBuf()
  {
    delete [] _buf;
  }

  RingBuf::RingBuf(const RingBuf& obj) :
    _buf(new char[obj._size]),
    _size(obj._size),
    _read(0),
    _write(0)
  {
    obj.copy(_buf, obj._size);
  }

  RingBuf& RingBuf::operator=(const RingBuf& obj)
  {
    RingBuf tmp(obj);
    swap(tmp);
    return (*this);
  }

  size_t	RingBuf::read(char* buf, size_t len)
  {
    size_t res = copy(buf, len);
    _read = (_read + res) % _size;
    return (res);
  }

  size_t	RingBuf::write(const char* buf, size_t len)
  {
    size_t i = 0;

    if (size() + len + 1 > _size)
      RingBuf::realloc((_size + len) + _size / 2 + 1);
    while (i < len)
      {
	_buf[_write] = buf[i];
	_write = (_write + 1 ) % _size;
	i++;
      }
    return (i);
  }

  void	RingBuf::swap(RingBuf& obj)
  {
    std::swap(_buf, obj._buf);
    std::swap(_size, obj._size);
    std::swap(_read, obj._read);
    std::swap(_write, obj._write);
  }

  size_t	RingBuf::size() const
  {
    if (_read <= _write)
      return _write - _read;
    return (_size - _read) + _write;
  }

  void		RingBuf::reserve(size_t size)
  {
    if (_size < size)
      realloc(size + 1);
  }

  void		RingBuf::clear()
  {
    _read = 0;
    _write = 0;
  }


  size_t	RingBuf::copy(char* buf, ssize_t len) const
  {
    size_t	ret = 0;
    size_t	i = _read;

    while (i != _write && (len < 0 || ret < static_cast<size_t>(len)))
      {
	buf[ret] = _buf[i];
	i = (i + 1) % _size;
	ret++;
      }
    return (ret);
  }

  void		RingBuf::realloc(size_t size)
  {
    char* tmp = new char[size];
    copy(tmp, -1);
    delete [] _buf;
    _buf = tmp;
    _size = size;
  }
}
