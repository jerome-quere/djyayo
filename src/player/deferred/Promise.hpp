/*
 * Copyright 2012 Jerome Quere < contact@jeromequere.com >.
 *
 * This file is part of Deferred.
 *
 * Deferred is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Deferred is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Deferred.If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _DF_PROMISE_HPP_
#define _DF_PROMISE_HPP_

#include <memory>

#include "DeferredData.hpp"

namespace Df
{
  template <typename T>
  class Deferred;

  template <typename T>
  class Promise
  {
    friend class Deferred<T>;

  public:
    Promise();
    ~Promise();
    Promise(const Promise&);
    Promise& operator=(const Promise&);

    void done(std::function<void (const T&)>);
    void fail(std::function<void (const std::string&)>);

    void clear();
    operator bool();

  private:
    Promise(std::shared_ptr<DeferredData<T> >);

    std::shared_ptr<DeferredData<T> >	_data;
  };
}

#include "Promise.hh"

#endif /* _DF_PROMISE_HPP_ */
