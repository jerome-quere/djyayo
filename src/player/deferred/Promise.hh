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

#ifndef _DF_PROMISE_HH_
#define _DF_PROMISE_HH_

namespace Df
{
  template <typename T>
  Promise<T>::Promise()
  {
  }

  template <typename T>
  Promise<T>::~Promise()
  {
  }

  template <typename T>
  Promise<T>::Promise(const Promise& obj)
  {
    operator=(obj);
  }

  template <typename T>
  Promise<T>& Promise<T>::operator=(const Promise& obj)
  {
    _data = obj._data;
    return (*this);
  }

  template <typename T>
  void Promise<T>::done(std::function<void (const T&)> f)
  {
    _data->done(f);
  }

  template <typename T>
  void Promise<T>::fail(std::function<void (const std::string&)> f)
  {
    _data->fail(f);
  }

  template <typename T>
  void Promise<T>::clear()
  {
    _data.reset();
  }

  template <typename T>
  Promise<T>::operator bool()
  {
    return static_cast<bool>(_data);
  }

  template <typename T>
  Promise<T>::Promise(std::shared_ptr<DeferredData<T> > data) :
    _data(data)
  {
  }

}

#endif /* _DF_PROMISE_HH_ */
