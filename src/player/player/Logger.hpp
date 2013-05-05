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

#include <fstream>
#include <string>

namespace Spdj
{
  class Logger
  {
    typedef std::ostream& (manip)(std::ostream&);

  public:
    Logger(const std::string& file);
    template <typename T> Logger& operator<<(const T&);
    Logger& operator<<(manip& m);
    void setFile(const std::string& file);

  private:
    std::fstream	_stream;
  };

  extern Logger logger;

  template <typename T>
  Logger& Logger::operator<<(const T& p)
  {
    _stream << p << std::endl;
    return (*this);
  }

}
