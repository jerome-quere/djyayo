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

#ifndef _RINGBUF_HPP_
#define _RINGBUF_HPP_

#include <cstdlib>

namespace Spdj
{

  class RingBuf
  {
  public:
    RingBuf();
    ~RingBuf();
    RingBuf(const RingBuf&);
    RingBuf& operator=(const RingBuf&);

    size_t	read(char* buf, size_t len);
    size_t	write(const char* buf, size_t len);

    void	swap(RingBuf&);
    size_t	size() const;
    void	reserve(size_t size);
    void	clear();

  private:

    size_t	copy(char* buf, ssize_t len) const;
    void	realloc(size_t size);

    char*	_buf;
    size_t	_size;
    size_t	_read;
    size_t	_write;
  };
}
#endif /* _RINGBUF_HPP_ */
