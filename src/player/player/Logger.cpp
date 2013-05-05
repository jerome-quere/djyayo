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

#include <iostream>
#include "Logger.hpp"

namespace Spdj
{
  Logger logger("/dev/stdout");

  Logger::Logger(const std::string& file)
  {
    _stream.open(file, std::ifstream::out);
  }

  void Logger::setFile(const std::string& file)
  {
    _stream.close();
    _stream.open(file, std::ifstream::out);
  }

  Logger& Logger::operator<<(manip& m)
  {
    std::cout << m;
    return (*this);
  }

}
