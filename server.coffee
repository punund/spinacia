_ = require 'lodash'
fs = require 'fs'
global.Conf = require('yaml-config').readConfig './config/app.yaml'

Util = require './modules/util'
DB = require './modules/database'

params = Conf.zappa_params
params.https = 
  key:  fs.readFileSync Conf.https.key
  cert: fs.readFileSync Conf.https.cert

require('zappajs') params, ->
  @use 'logger'
  @get /\/(.*)/, ->
    tree_id = @params[0] or 'main'

    domain = @req.header Conf.api.domain
    token  = @req.header Conf.api.token

    unless domain and token
      @send 400, "#{Conf.api.domain} and #{Conf.api.token} header values required"
      return

    DB.Seed.findOne id: domain, (err, seed) =>
      switch
        when err
          @res.send 503, 'Database error'
        when not seed
          @send 404, 'No such tree in this domain'
        else
          tree = (_.filter seed.trees, (tree) -> tree.id is tree_id)?[0]
          match = Util.compareTreeKey token, tree.key
          if match
            console.log tree
            @json 200, tree.data
          else
            @send 403, 'Token doesn\'t match'
