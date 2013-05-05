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

#ifndef _DF_DEFERRED_DATA_HH_
#define _DF_DEFERRED_DATA_HH_

namespace Df
{
  template <typename T>
  DeferredData<T>::DeferredData()
  {
    _state = WAITING;
  }

  template <typename T>
  void DeferredData<T>::resolve(const T& value)
  {
    std::lock_guard<std::mutex> l(_lock);

    _value = value;
    _state = SUCCESS;
    for (auto f : _thenCbs)
      f(_value);
  }

  template <typename T>
  void DeferredData<T>::reject(const std::string& error)
  {
    std::lock_guard<std::mutex> l(_lock);

    _error = error;
    _state = ERROR;
    for (auto f : _failCbs)
      f(_error);
  }

  template <typename T>
  void DeferredData<T>::done(std::function<void (const T&)> f)
  {
    std::lock_guard<std::mutex> l(_lock);

    if (_state == SUCCESS)
      {
	f(_value);
	return;
      }
    _thenCbs.push_back(f);
  }

  template <typename T>
  void DeferredData<T>::fail(std::function<void (const std::string&)> f)
  {
    std::lock_guard<std::mutex> l(_lock);

    if (_state == ERROR)
      {
	f(_error);
	return;
      }
    _failCbs.push_back(f);
  }
}

#endif /* _DF_DEFERRED_DATA_HH_ */
