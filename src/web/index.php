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
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Spotify - Dj</title>
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link type="text/css" rel="stylesheet" href="css/bootstrap/bootstrap.min.css" />
    <link type="text/css" rel="stylesheet" href="css/bootstrap/bootstrap-responsive.min.css" />
    <link type="text/css" rel="stylesheet" href="css/style.css" />
    <script src="js/jquery/jquery-1.7.2.min.js"></script>
    <script src="js/bootstrap/bootstrap.min.js"></script>
    <script src="js/knockout/knockout-2.0.0.js"></script>
    <script src="js/sammy/sammy.min.js"></script>
    <script src="js/script.js?version=<?=time()?>"></script>
  </head>
  <body>
    <div id="panels">
      <div id="panel_search" class="panel" style="o%"><?include("./src/web/pages/searchPanel.php")?></div>

      <script>
	$(function() {
	  $(".panel").Panel({wrap: "#wrap"});
	});
      </script>
    </div>
    <div id="wrap">
      <div id="header">
	<a class="search-ico" herf="" onclick="$('#panel_search').data('panel').show();">
	  <img width="30px" src="images/search.png" />
	</a>
        <a href="#">
	  <span class="logo searchPanelTrigger">Spotify DJ</span>
	</a>
      </div>
      <div id="pages">
	<div class="page" id="page_home"><?include("./src/web/pages/home.php") ?></div>
	<div class="page" id="page_debug"><?include("./src/web/pages/debug.php") ?></div>
      </div>
      <div id="push"></div>
    </div>
    <footer>
      <div style="text-align: center;line-height: 42px; color: #fff">
        By Yayo
      </div>
    </footer>
  </body>
</html>
