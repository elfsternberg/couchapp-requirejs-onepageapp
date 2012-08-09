var async, coffee, fs, path;

path = require("path");

async = require("async");

fs = require("fs");

coffee = require('coffee-script');

module.exports = function(grunt) {
  grunt.loadNpmTasks("grunt-coffee");
  grunt.loadNpmTasks("grunt-requirejs");
  grunt.initConfig({
    pkg: "<json:CouchappRequirejsOnepage.json>",
    meta: {
      banner: "/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + "<%= pkg.homepage ? \"* \" + pkg.homepage + \"\n\" : \"\" %>" + "* Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>;" + " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %> */"
    },
    concat: {
      dist: {
        src: ["<banner:meta.banner>", "<file_strip_banner:src/<%= pkg.name %>.js>"],
        dest: "dist/<%= pkg.name %>.js"
      }
    },
    min: {
      dist: {
        src: ["<banner:meta.banner>", "<config:concat.dist.dest>"],
        dest: "dist/<%= pkg.name %>.min.js"
      }
    },
    qunit: {
      files: ["test/**/*.html"]
    },
    lint: {
      files: ["grunt.js", "src/**/*.js", "test/**/*.js"]
    },
    watch: {
      files: "<config:lint.files>",
      tasks: "lint qunit"
    },
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
    haml: {
      dev: {
        src: ['src/index.haml'],
        dest: 'app/attachments/'
      }
    },
    coffee: {
      app: {
        src: ['src/app.coffee'],
        dest: 'app/'
      },
      client: {
        src: ['src/client.coffee', 'src/library.coffee'],
        dest: 'dist/'
      }
    },
    requirejs: {
      dir: 'dist-compiled',
      appDir: 'dist',
      baseUrl: '.',
      paths: {
        'jquery': '../libs/jquery/jquery'
      },
      deps: ['../libs/require/require'],
      modules: [
        {
          name: "client"
        }
      ]
    },
    couchapp: {
      demo: {
        app: 'app/app.js',
        db: 'http://localhost:5984/demo-couchapp'
      }
    },
    install: {
      appclient: {
        src: ['dist-compiled/client.js'],
        dest: 'app/attachments/js'
      }
    },
    recess: {
      dev: {
        src: ["src/style.less"],
        dest: "dist/style.css",
        options: {
          compile: true
        }
      }
    }
  });
  grunt.registerTask("default", "coffee:app coffee:client requirejs install:appclient haml:dev couchapp:demo");
  grunt.registerTask("test", "default qunit");
  grunt.registerMultiTask("couchapp", "Install Couchapp", function() {
    var appobj, couchapp, done;
    couchapp = require('couchapp');
    appobj = require(path.join(process.cwd(), path.normalize(this.data.app)));
    done = this.async();
    return couchapp.createApp(appobj, this.data.db, function(app) {
      return app.push(done);
    });
  });
  grunt.registerHelper("haml", function(src, dest, done) {
    var args;
    args = {
      cmd: "haml",
      args: ["--unix-newlines", "--no-escape-attrs", "--double-quote-attributes", src]
    };
    return grunt.utils.spawn(args, function(err, result) {
      var out;
      if (err) {
        console.log(err);
      }
      out = path.basename(src, ".haml");
      grunt.file.write(path.join(dest, out + ".html"), result.stdout);
      return done();
    });
  });
  grunt.registerMultiTask("haml", "Compile HAML", function() {
    var dest, done, sources;
    done = this.async();
    sources = grunt.file.expandFiles(this.file.src);
    dest = this.file.dest;
    return async.forEachSeries(sources, (function(path, cb) {
      return grunt.helper("haml", path, dest, cb);
    }), done);
  });
  grunt.registerTask("gruntjs", "convert grunt.coffee to grunt.js", function() {
    var cFileName, cSource, cStat, cmTime, jFileName, jSource, jStat, jmTime;
    jFileName = path.join(__dirname, "grunt.js");
    cFileName = path.join(__dirname, "grunt.coffee");
    jStat = fs.statSync(jFileName);
    cStat = fs.statSync(cFileName);
    jmTime = jStat.mtime;
    cmTime = cStat.mtime;
    if (cmTime < jmTime) {
      grunt.verbose.writeln("grunt.js newer than grunt.coffee, skipping compile");
      return;
    }
    cSource = fs.readFileSync(cFileName, "utf-8");
    try {
      jSource = coffee.compile(cSource, {
        bare: true
      });
    } catch (e) {
      grunt.fail.fatal(e);
    }
    fs.writeFileSync(jFileName, jSource, "utf-8");
    return grunt.log.writeln("compiled " + cFileName + " to " + jFileName);
  });
  grunt.registerHelper("install", function(src, dest, done) {
    grunt.file.copy(src, path.join(dest, path.basename(src)));
    if (done) {
      return done();
    }
  });
  return grunt.registerMultiTask("install", "Install Files", function() {
    var dest, sources;
    sources = grunt.file.expandFiles(this.file.src);
    dest = this.file.dest;
    return sources.forEach(function(path) {
      return grunt.helper("install", path, dest, null);
    });
  });
};
