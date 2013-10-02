<?php

$DEBUG = false;
if (isset($argv[1]) && $argv[1] == '-v')
  $DEBUG = true;

?>
<!DOCTYPE html>
<html lang="en" ng-app="spotifyDj">
  <head>
    <meta charset="utf-8">
    <title>Spotify - Dj</title>
    <meta name="author" content="Yayo<contact@jeromequere.com>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?if ($DEBUG):?>
      <link type="text/css" rel="stylesheet" href="css/bootstrap/bootstrap.min.css" />
      <link type="text/css" rel="stylesheet" href="css/font-awesome/font-awesome.min.css" />
      <link type="text/css" rel="stylesheet/less" href="css/less/style.less" />
      <link type="text/css" rel="stylesheet" href="css/social-buttons.min.css" />
      <script src="js/jquery/jquery-1.7.2.min.js"></script>
      <script src="js/bootstrap/bootstrap.min.js"></script>
      <script src="js/less/less-1.4.1.min.js"></script>
      <script src="js/EventEmmiter/EventEmitter-4.0.3.min.js"></script>
      <script src="js/socket.io/socket.io.js"></script>
      <script src="js/angular/angular.min.js"></script>
      <script src="js/angular/angular-route.min.js"></script>
      <script src="js/script.js"></script>
    <?else:?>
      <link type="text/css" rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" />
      <link type="text/css" rel="stylesheet" href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.min.css" />
      <link type="text/css" rel="stylesheet" href="css/style.min.css" />
      <script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
      <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
      <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.0-rc.2/angular.min.js"></script>
      <script src="//ajax.googleapis.com/ajax/libs/angularjs/1.2.0-rc.2/angular-route.min.js"></script>
      <script src="js/script.min.js"></script>
    <?endif;?>
  </head>
  <body>
    <div id="panels">
      <div id="panel_menu" class="panel" ng-controller="MenuPanelController">
	<div class="listView-mini">
	  <ul class="listView-mini">
	    <li>
	      <img class="thumbmail" ng-src="{{user.imgUrl}}"/>
	      <h2>Hello {{user.name}} !</h2>
	      <a href="#" ng-click="logout()" class="icon">
		<i class="icon-signout" ></i>
	      </a>
	    </li>
	    <li ng-show="room.name">
	      <a href="#" ng-click="changeRoom()">
		<i class="thumbmail icon-reply"></i>
		<h2>Change Room</h2>
	      </a>
	    </li>
	    <li ng-show="room.name">
	      <a href="javascript:" ng-click="goToTrackQueue()">
		<i class="thumbmail icon-music"></i>
		<h2>Track Queue</h2>
	      </a>
	    </li>
	    <li ng-show="room.name">
	      <a href="javascript:" ng-click="goToSearch()">
		<i class="thumbmail icon-search"></i>
		<h2>Search</h2>
	      </a>
	    </li>
	  </ul>
	</div>
      </div>
      <script>
	$(function() {
	  $(".panel").Panel({wrap: "#wrap"});
	});
      </script>
    </div>
    <div id="wrap">
      <div id="header" ng-controller="HeaderController">
	<a ng-show="user.isLog" class="menu-ico" herf="" onclick="$('#panel_menu').data('panel').show();">
	  <i class="icon-reorder"></i>
	</a>
	<table ng-show="user.isLog" class="user-infos">
	  <tr>
	    <td rowspan="2"></td>
	    <td>Hello <b>{{user.name}}</b></td>
	  </tr>
	  <tr>
	    <td><a href="#" ng-click="logout()">Logout</a></td>
	  </tr>
	</table>
      </div>
      <div ng-view></div>
      <div id="push"></div>
    </div>
    <div id="fb-root"></div>
  </body>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-31304821-3', 'yayo.fr');
  ga('send', 'pageview');

</script>
</html>
