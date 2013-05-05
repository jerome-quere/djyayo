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

#ifndef _DF_DEFERRED_HPP_
#define _DF_DEFERRED_HPP_

#include "Promise.hpp"
#include "Resolver.hpp"

namespace Df
{
  template <typename T>
  class Deferred
  {
  public:
    Deferred();
    ~Deferred();
    Deferred(const Deferred&);
    Deferred& operator=(const Deferred&);

    Promise<T>& promise();
    Resolver<T>& resolver();

  private:

    std::shared_ptr<DeferredData<T> > _data;
    Promise<T>		  _promise;
    Resolver<T>		  _resolver;
  };

};

#include "Deferred.hh"

#endif /* _DF_DEFERRED_HPP_ */
