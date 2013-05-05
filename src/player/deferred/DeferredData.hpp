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

#ifndef _DF_DEFERRED_DATA_HPP_
#define _DF_DEFERRED_DATA_HPP_

#include <functional>
#include <list>
#include <mutex>

namespace Df
{
  template <typename T>
  class Deferred;

  template <typename T>
  class Promise;

  template <typename T>
  class Resolver;


  template <typename T>
  class DeferredData
  {
    friend class Deferred<T>;
    friend class Promise<T>;
    friend class Resolver<T>;

    DeferredData();
    DeferredData(const DeferredData&) = delete;

    void resolve(const T&);
    void reject(const std::string&);
    void done(std::function<void (const T&)>);
    void fail(std::function<void (const std::string&)>);

    enum State
      {
	WAITING,
	SUCCESS,
	ERROR
      };


    T _value;
    std::string _error;
    State _state;
    std::mutex _lock;
    std::list<std::function<void (const T&)> > _thenCbs;
    std::list<std::function<void (std::string&)> > _failCbs;
  };

};

#include "DeferredData.hh"

#endif /* _DF_DEFERRED_DATA_HPP_ */
