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
<h1>Debug</h1>
<form>
  <label>Url: </label><input type="text" name="url" size="100" data-bind="value: url" /><br/>
  <label>Data: </label><input type="text" name="data" size="100" data-bind="value: data" /><br/>
  <input type="button" value="Submit" data-bind="click: onSubmitClick" />
</form>
<div width="1000px">
</div>
