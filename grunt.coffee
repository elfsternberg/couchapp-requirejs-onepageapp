path = require "path"
async = require "async"
fs = require "fs"
coffee = require 'coffee-script'

module.exports = (grunt) ->
    grunt.loadNpmTasks "grunt-coffee"
    grunt.loadNpmTasks "grunt-requirejs"

    grunt.initConfig
        pkg: "<json:CouchappRequirejsOnepage.json>"
        meta:
            banner: "/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + "<%= pkg.homepage ? \"* \" + pkg.homepage + \"\n\" : \"\" %>" + "* Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>;" + " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %> */"

        concat:
            dist:
                src: [ "<banner:meta.banner>", "<file_strip_banner:src/<%= pkg.name %>.js>" ]
                dest: "dist/<%= pkg.name %>.js"

        min:
            dist:
                src: [ "<banner:meta.banner>", "<config:concat.dist.dest>" ]
                dest: "dist/<%= pkg.name %>.min.js"

        qunit:
            files: [ "test/**/*.html" ]

        lint:
            files: [ "grunt.js", "src/**/*.js", "test/**/*.js" ]

        watch:
            files: "<config:lint.files>"
            tasks: "lint qunit"


        jshint:
            options:
                curly: true
                eqeqeq: true
                immed: true
                latedef: true
                newcap: true
                noarg: true
                sub: true
                undef: true
                boss: true
                eqnull: true
                browser: true

            globals:
                jQuery: true


        #   ___             ___ _         __  __
        #  / _ \ _  _ _ _  / __| |_ _  _ / _|/ _|
        # | (_) | || | '_| \__ \  _| || |  _|  _|
        #  \___/ \_,_|_|   |___/\__|\_,_|_| |_|
        #

        haml:
            dev:
                src: ['src/index.haml']
                dest: 'app/attachments/'

        coffee:
            app:
                src: ['src/app.coffee']
                dest: 'app/'

            client:
                src: ['src/client.coffee', 'src/library.coffee']
                dest: 'dist/'

        requirejs:
            dir: 'dist-compiled'
            appDir: 'dist'
            baseUrl: '.'
            paths:
                'jquery': '../libs/jquery/jquery'
            deps: ['../libs/require/require']
            modules: [
                {
                    name: "client"
                }
            ]

        couchapp:
            demo:
                app: 'app/app.js'
                db: 'http://localhost:5984/demo-couchapp'

        install:
            appclient:
                src: ['dist-compiled/client.js']
                dest: 'app/attachments/js'

        recess:
            dev:
                src: ["src/style.less"]
                dest: "dist/style.css"
                options:
                    compile: true


    grunt.registerTask "default", "coffee:app coffee:client requirejs install:appclient haml:dev couchapp:demo"
    grunt.registerTask "test", "default qunit"

    #  ___         _        _ _    ___             _
    # |_ _|_ _  __| |_ __ _| | |  / __|___ _  _ __| |_  __ _ _ __ _ __
    #  | || ' \(_-<  _/ _` | | | | (__/ _ \ || / _| ' \/ _` | '_ \ '_ \
    # |___|_||_/__/\__\__,_|_|_|  \___\___/\_,_\__|_||_\__,_| .__/ .__/
    #                                                       |_|  |_|

    grunt.registerMultiTask "couchapp", "Install Couchapp", ->
        couchapp = require 'couchapp'
        appobj = require(path.join(process.cwd(), path.normalize(this.data.app)))
        done = @async()
        couchapp.createApp appobj, this.data.db, (app) ->
            app.push(done)

    #  _  _   _   __  __ _      _         _  _ _____ __  __ _
    # | || | /_\ |  \/  | |    | |_ ___  | || |_   _|  \/  | |
    # | __ |/ _ \| |\/| | |__  |  _/ _ \ | __ | | | | |\/| | |__
    # |_||_/_/ \_\_|  |_|____|  \__\___/ |_||_| |_| |_|  |_|____|
    #

    grunt.registerHelper "haml", (src, dest, done) ->
        args =
          cmd: "haml"
          args: [ "--unix-newlines", "--no-escape-attrs", "--double-quote-attributes", src ]

        grunt.utils.spawn args, (err, result) ->
            console.log err  if err
            out = path.basename(src, ".haml")
            grunt.file.write path.join(dest, out + ".html"), result.stdout
            done()

    grunt.registerMultiTask "haml", "Compile HAML", ->
        done = @async()
        sources = grunt.file.expandFiles(this.file.src)
        dest = this.file.dest
        async.forEachSeries sources, ((path, cb) ->
            grunt.helper "haml", path, dest, cb
        ), done

    #   ___              _    ___      __  __
    #  / __|_ _ _  _ _ _| |_ / __|___ / _|/ _|___ ___
    # | (_ | '_| || | ' \  _| (__/ _ \  _|  _/ -_) -_)
    #  \___|_|  \_,_|_||_\__|\___\___/_| |_| \___\___|
    #

    grunt.registerTask "gruntjs", "convert grunt.coffee to grunt.js", ->
        jFileName = path.join __dirname, "grunt.js"
        cFileName = path.join __dirname, "grunt.coffee"

        jStat = fs.statSync jFileName
        cStat = fs.statSync cFileName

        jmTime = jStat.mtime
        cmTime = cStat.mtime

        if cmTime < jmTime
            grunt.verbose.writeln "grunt.js newer than grunt.coffee, skipping compile"
            return

        cSource = fs.readFileSync cFileName, "utf-8"

        try
            jSource = coffee.compile cSource,
                bare: true
        catch e
            grunt.fail.fatal e

        fs.writeFileSync jFileName, jSource, "utf-8"

        grunt.log.writeln "compiled #{cFileName} to #{jFileName}"

    #   ___
    #  / __|___ _ __ _  _
    # | (__/ _ \ '_ \ || |
    #  \___\___/ .__/\_, |
    #          |_|   |__/

    grunt.registerHelper "install", (src, dest, done) ->
        grunt.file.copy src, path.join(dest, path.basename(src))
        done() if done

    grunt.registerMultiTask "install", "Install Files", ->
        sources = grunt.file.expandFiles(this.file.src)
        dest = this.file.dest
        sources.forEach (path) ->
            grunt.helper "install", path, dest, null
