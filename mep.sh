#!/bin/sh

BASEDIR=$(dirname $0)
WEBDIR=$BASEDIR/src/web

php $WEBDIR/index.html.php > $WEBDIR/index.html
(lessc $WEBDIR/css/less/style.less ; cat $WEBDIR/css/social-buttons.min.css) > $WEBDIR/css/style.min.css
(yuicompressor $WEBDIR/js/EventEmmiter/EventEmitter-4.0.3.min.js ; yuicompressor $WEBDIR/js/socket.io/socket.io.js ; yuicompressor $WEBDIR/js/script.js) > $WEBDIR/js/script.min.js
