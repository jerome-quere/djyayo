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

#ifndef _DF_REOLVER_HH_
#define _DF_REOLVER_HH_

namespace Df
{
  template <typename T>
  Resolver<T>::Resolver()
  {
  }

  template <typename T>
  Resolver<T>::~Resolver()
  {
  }

  template <typename T>
  Resolver<T>::Resolver(const Resolver& obj)
  {
    operator=(obj);
  }

  template <typename T>
  Resolver<T>& Resolver<T>::operator=(const Resolver& obj)
  {
    _data = obj._data;
    return (*this);
  }

  template <typename T>
  void Resolver<T>::resolve(const T& value)
  {
    _data->resolve(value);
  }

  template <typename T>
  void Resolver<T>::reject(const std::string& error)
  {
    _data->reject(error);
  }

  template <typename T>
  void Resolver<T>::clear()
  {
    _data.reset();
  }

  template <typename T>
  Resolver<T>::operator bool()
  {
    return static_cast<bool>(_data);
  }

  template <typename T>
  Resolver<T>::Resolver(std::shared_ptr<DeferredData<T> > data) :
    _data(data)
  {
  }
}

#endif /* _DF_REOLVER_HH_ */
