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

#ifndef _DF_DEFERRED_HH_
#define _DF_DEFERRED_HH_

namespace Df
{
  template <typename T>
  Deferred<T>::Deferred() :
    _data(new DeferredData<T>()),
    _promise(_data),
    _resolver(_data)
  {
  }

  template <typename T>
  Deferred<T>::~Deferred()
  {
  }

  template <typename T>
  Deferred<T>::Deferred(const Deferred& obj)
  {
    operator=(obj);
  }

  template <typename T>
  Deferred<T>& Deferred<T>::operator=(const Deferred& obj)
  {
    _data = obj._data;
    _promise = obj._promise;
    _resolver = obj._resover;
    return (*this);
  }

  template <typename T>
  Promise<T>& Deferred<T>::promise()
  {
    return _promise;
  }

  template <typename T>
  Resolver<T>& Deferred<T>::resolver()
  {
    return _resolver;
  }
}

#endif /* _DF_DEFERRED_HPP_ */
