# CouchApp/RequireJS One Page Application Demo

This basically scratches a major itch I've had for a while: is it
possible to automate the integration of 

    (1) CouchDB one-page apps with

    (2) javascript one-page applications optimized with RequireJS?

The answer is this project.

## Getting Started

You will need: Node.js and the Ruby version of Haml.  You might need
the global version of require.js (r.js) installed; I do, so I haven't
tested without it.

This project is written in Coffeescript and HAML, and uses Grunt as its
build tool.  You should have a copy of CouchDB running in "AdminParty
mode."  The best way I've found recently to get CouchDB running is to
use docker.  The base CouchDB image from Apache is fine.  For example,
from the project directory:

    $ docker pull couchdb
    $ mkdir data
    $ docker run -d -p 5984:5984 -v $(pwd)/data:/usr/local/var/lib/couchdb --name my-couchdb couchdb

This command will start CouchDB in a docker container with a fairly
small instance of the Erlang BEAM, expose CouchDB's port on localhost,
and export the docker's internal storage volume to your local filesytem
in the new 'data' directory.

As with all NPM-based projects, you should run:

    $ npm install

to get started.  A pair of convenience scripts are located in the
'bin/' directory.  From the root of the application, when in Bash or a
related shell, run:

    $ source bin/activate

This will put all of the executables installed in
"./node_modules/.bin" into your path, making them available to you
(and grunt).  Now create a new database:

    $ curl -X PUT http://localhost:5984/demo-couchapp

Now run the build and install:

    $ gruntc

And now it should be possible to browse to 

http://localhost:5984/demo-couchapp/_design/app/index.html

... and see "Yes, it worked!" in blue.

If it did not work, the page will say "Did it work?"

## Documentation

There are a number of valuable little snippets of code in here.  

First, there are a slew of useful, tiny Grunt.JS tools: HAMLtoHTML,
InstallCouchApp, and just plain "copy".  These all demonstrate how to
create small GruntJS recipes and are fairly clear.

Secondly, the "requirejs" GruntJS configuration shows how to force the
optimizer to include require() as part of the final product.  This is
critical to ensuring that it's available to the final, compiled app.

And finally, as a framework for developing fast, efficient CouchApps
in Coffeescript, this is pretty invaluable stuff.  After I work in my
HAMLtoJS features (no, really, you'll see!  I'll show you, I'll show
you all! Muahahahahah!) and a consistent working op for recess, this
will be the framework many of my tools will be in, going into the
future.

## Contributing

In lieu of a formal styleguide, take care to maintain the existing
coding style. Add unit tests for any new or changed
functionality. Lint and test your code using
[grunt](https://github.com/cowboy/grunt).

## License
Copyright (c) 2012 Ken Elf Mathieu Sternberg  
Licensed under the MIT license.

The libraries packaged with this demonstration are copyright their
respective owners.
