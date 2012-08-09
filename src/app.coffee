couchapp = require('couchapp')
path = require('path')

ddoc =
    _id:'_design/app'

    rewrites: {}
    views: {}
    shows: {}
    lists: {}

    validate_doc_update: (newDoc, oldDoc, userCtx) ->
        if newDoc._deleted == true && userCtx.roles.indexOf('_admin') == -1
            throw "Only admin can delete documents on this database.";


couchapp.loadAttachments ddoc, path.join(__dirname, 'attachments')

module.exports = ddoc

