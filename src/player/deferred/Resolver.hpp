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

#ifndef _DF_RESOLVER_HPP_
#define _DF_RESOLVER_HPP_

namespace Df
{
  template <typename T>
  class Deferred;

  template <typename T>
  class Resolver
  {
    friend class Deferred<T>;

  public:
    Resolver();
    ~Resolver();
    Resolver(const Resolver&);
    Resolver& operator=(const Resolver&);

    void resolve(const T&);
    void reject(const std::string&);

    void clear();
    operator bool();

  private:
    Resolver(std::shared_ptr<DeferredData<T> >);

    std::shared_ptr<DeferredData<T> >	_data;
  };
}

#include "Resolver.hh"

#endif /* _DF_RESOLVER_HPP_ */
