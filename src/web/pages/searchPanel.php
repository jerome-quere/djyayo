<?php
/*
* Copyright 2012 Jerome Quere < contact@jeromequere.com >.
*
* This file is part of SpotifyDJ.
*
* SpotifyDJ is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* SpotifyDJ is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with SpotifyDJ.If not, see <http://www.gnu.org/licenses/>.
*/
?>
<div class="list-search">
  <form class="form-search">
    <input type="text" class="search-query" data-bind="value: searchInput, valueUpdate: 'afterkeyup'" />
  </form>
</div>
<ul class="listView listView-nothumbs"  data-bind="foreach: results">
  <li data-bind="click: $root.onTrackClick">
    <h2 data-bind="text: trackName">...</h2>
    <p data-bind="text: artistName">...</p>
    <img class="icon" data-bind="attr: {src: haveMyVote() ? 'images/star.png' : 'images/star_empty.png'}"/>
  </li>
</ul>
