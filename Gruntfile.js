module.exports = function( grunt ) {
  'use strict';
  //
  // Grunt configuration:
  //
  // https://github.com/cowboy/grunt/blob/master/docs/getting_started.md
  //
  grunt.initConfig({

    // Project configuration
    // ---------------------

    // specify an alternate install location for Bower
    bower: {
      dir: 'app/components'
    },

    // Coffee to JS compilation
    coffee: {
      compile: {
        files: {
          'temp/scripts/*.js': 'app/scripts/**/*.coffee',
          'temp/lib/*.js': 'app/lib/**/*.coffee',
          'temp/edit/scripts/*.js': 'app/edit/scripts/**/*.coffee'
        },
        options: {
          basePath: ['app/scripts', 'lib']
        }
      }
    },

    // compile .scss/.sass to .css using Compass
    compass: {
      dist: {
        // http://compass-style.org/help/tutorials/configuration-reference/#configuration-properties
        options: {
          css_dir: 'temp/styles',
          sass_dir: 'app/styles',
          images_dir: 'app/img',
          javascripts_dir: 'temp/scripts',
          force: true
        }
      }
    },

    // generate application cache manifest
    manifest:{
      dest: ''
    },

    // headless testing through PhantomJS
    mocha: {
      all: ['test/**/*.html']
    },

    // default watch configuration
    watch: {
      coffee: {
        files: [
          'app/scripts/**/*.coffee',
          'app/edit/scripts/**/*.coffee',
          'app/lib/**/*.coffee',
        ],
        tasks: 'coffee reload'
      },
      compass: {
        files: [
          'app/styles/**/*.{scss,sass}',
          'app/edit/styles/**/*.{scss,sass}'
        ],
        tasks: 'compass reload'
      },
      reload: {
        files: [
          'app/*.html',
          'app/styles/**/*.css',
          'app/scripts/**/*.js',
          'app/img/**/*',
          'app/edit/*.html',
          'app/edit/styles/**/*.css',
          'app/edit/scripts/**/*.js',
          'app/edit/img/**/*'
        ],
        tasks: 'reload'
      }
    },

    // default lint configuration, change this to match your setup:
    // https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#lint-built-in-task
    lint: {
      files: [
        'Gruntfile.js',
        'app/scripts/**/*.js',
        'spec/**/*.js'
      ]
    },

    // specifying JSHint options and globals
    // https://github.com/cowboy/grunt/blob/master/docs/task_lint.md#specifying-jshint-options-and-globals
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true
      },
      globals: {
        jQuery: true
      }
    },

    // Build configuration
    // -------------------

    // the staging directory used during the process
    staging: 'temp',
    // final build output
    output: 'dist',

    mkdirs: {
      staging: 'app/'
    },

    // Below, all paths are relative to the staging directory, which is a copy
    // of the app/ directory. Any .gitignore, .ignore and .buildignore file
    // that might appear in the app/ tree are used to ignore these values
    // during the copy process.

    // concat css/**/*.css files, inline @import, output a single minified css
    css: {
      // 'styles/site.css': ['styles/bootstrap.css', 'styles/site.css'],
      // 'edit/styles/cmx.css': ['edit/styles/cmx.css', 'edit/styles/cmx-overlay.css'],
      // 'edit/styles/editor.css': ['edit/styles/editor.css']
    },

    // renames JS/CSS to prepend a hash of their contents for easier
    // versioning
    rev: {
      js: 'scripts/**/*.js',
      css: 'styles/**/*.css',
      img: 'img/**'
    },

    // usemin handler should point to the file containing
    // the usemin blocks to be parsed
    'usemin-handler': {
      html: ['edit/sample.html', 'edit/index.html', 'index.html']
    },

    // update references in HTML/CSS to revved files
    usemin: {
      html: ['*.html', 'edit/*.html'],
      css: ['**/*.css']
    },

    // HTML minification
    html: {
      files: ['**/*.html']
    },

    // Optimizes JPGs and PNGs (with jpegtran & optipng)
    img: {
      dist: '<config:rev.img>'
    },

    // rjs configuration. You don't necessarily need to specify the typical
    // `path` configuration, the rjs task will parse these values from your
    // main module, using http://requirejs.org/docs/optimization.html#mainConfigFile
    //
    // name / out / mainConfig file should be used. You can let it blank if
    // you're using usemin-handler to parse rjs config from markup (default
    // setup)
    rjs: {
      // no minification, is done by the min task
      optimize: 'none',
      baseUrl: './edit/scripts',
      mainFile: 'edit/sample.html',
      wrap: true,
      name: 'main'
    },

    // While Yeoman handles concat/min when using
    // usemin blocks, you can still use them manually
    concat: {
      dist: ''
    },

    min: {
      dist: ''
    }
  });

  // Alias the `test` task to run the `mocha` task instead
  grunt.registerTask('test', 'server:phantom mocha');

  // Yeoman's usemin task expects our html files to be resident in app's root only
  // I was unable to use relative paths in build blocks in app/edit/*.html files
  grunt.registerTask('custom-hack', 'my fix', function(target) {
    grunt.log.subhead('Running custom-fix');
    var execSync = require('exec-sync');
    execSync('cp -r edit/scripts/* scripts');
    execSync('cp -r edit/styles/* styles');
  });

  grunt.registerTask('custom-build', 'my build', function(target) {
    var tasks = 'intro clean coffee compass mkdirs usemin-handler rjs custom-hack concat css img usemin manifest copy time';
    grunt.log.subhead('Running custom-build')
    grunt.task.run(tasks);
  });

};
