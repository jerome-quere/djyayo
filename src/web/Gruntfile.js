/*global module:false*/
module.exports = function(grunt)
{
  grunt.initConfig({
      meta: { version: '0.1.0' },

      coffee: {
	  compile: {
	      options: {
		  bare: true
	      },
	      files:
	      {
		  'js/script.js': ['js/coffee/EventEmitter.coffee', 'js/coffee/*.coffee']
	      }
	  }
      },
      less: {
	  developement: {
	      files: {
		  "css/style.css": ["css/less/*.less", "!css/less/.#*"]
	      }
	  }
      },
      uglify: {
	  jsVendor: {
              src: 'js/vendor.js',
              dest: 'js/vendor.js'
	  },
      },
      cssmin: {
	  combine: {
	      files: {
		  'css/vendor.css': ['css/vendor.css']
	      }
	  }
      },
      concat: {
	  jsVendor: {
	      src: ["js/vendor/jquery-2.0.3.min.js", "js/vendor/angular.min.js", "js/vendor/*.js"],
	      dest: "js/vendor.js"
	  },
	  cssVendor: {
	      src: ["css/vendor/bootstrap.min.css", "css/vendor/*.css"],
	      dest: "css/vendor.css"
	  }
      },
      watch: {
	  coffee: {
	      files: ['js/coffee/*.coffee', '!.*.coffee'],
	      tasks: ['coffee'],
	  },
	  less:{
	      files: ['css/less/*.less', '!css/less/.#*'],
	      tasks: ['less']

	  },
	  vendor: {
	      files: ['js/vendor/**/*'],
	      tasks: ['concat', 'uglify'],
	  }
      },

      connect: {
	   server: {
	       options: {
		   port: 8000,
		   base: '.',
		   keepalive: true,
		   hostname: '*'
	       }
	   }
      },

  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-connect');

  // Default task.
  grunt.registerTask('default', ['coffee', 'less', 'concat', 'cssmin', 'uglify']);

};
