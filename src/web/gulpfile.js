var gulp = require('gulp'),
clean    = require('gulp-clean'),
coffee   = require('gulp-coffee'),
connect  = require('gulp-connect'),
concat   = require('gulp-concat'),
less     = require('gulp-less'),
uglify   = require('gulp-uglify'),
minify   = require('gulp-minify-css'),
modRewrite = require('connect-modrewrite');

gulp.task('coffee', function () {
    return gulp.src(['js/coffee/*.coffee', "!js/coffee/.#*"])
	.pipe(coffee({bare: true}))
	.pipe(concat('script.js'))
	.pipe(gulp.dest('js/'));
});


gulp.task('less', function () {
    return gulp.src(["css/less/*.less", "!css/less/.#*"])
	.pipe(less())
	.pipe(concat('style.css'))
	.pipe(gulp.dest('css/'));
});

gulp.task('js-vendor', function () {
    return gulp.src('js/vendor/*.js')
	.pipe(concat('vendor.js'))
	.pipe(uglify())
	.pipe(gulp.dest('js/'))
});

gulp.task('css-vendor', function () {
    return gulp.src('css/vendor/*.css')
	.pipe(concat('vendor.css'))
	.pipe(minify())
	.pipe(gulp.dest('css/'))
});


gulp.task('clean', function () {
    return gulp.src(['css/vendor.css', 'js/vendor.js', 'css/style.css', 'js/script.js'], {read: false})
	.pipe(clean());
});

gulp.task('connect', function () {
    connect.server({
	root: __dirname,
	port: 8000,
	open:false,
	middleware: function (connect, opt) {
	    return [modRewrite([
		'^(.*\.(js|css|gif|jpg|png|html|woff)(\\?.*)?)$ /$1 [L]',
		'^(.*)$ /index.html'
	    ])];
	}
    })
});

gulp.task('watch', function () {
     gulp.watch('js/coffee/*.coffee', ['coffee']);
     gulp.watch(['css/less/*.less', "!css/less/.#*"], ['less']);
     gulp.watch('js/vendor/*.js', ['js-vendor']);
     gulp.watch('css/vendor/*.css', ['css-vendor']);
});

gulp.task('default', ['coffee', 'less', 'js-vendor', 'css-vendor']);
gulp.task('dev', ['default', 'watch', 'connect'])
