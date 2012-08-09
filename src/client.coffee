require.config
    paths:
        'jquery': '../libs/jquery/jquery'

require ['jquery', 'library'], ($, doit) ->
    $ ->
        doit()

