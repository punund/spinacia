_ = require 'lodash'
global.Conf = require('yaml-config').readConfig './config/app.yaml'

Util = require './modules/util'
DB = require './modules/database'

console.log Util
console.log Util.compareTreeKey

require('zappajs') (Conf.server.port or process.env.port), Conf.zappa_params, ->
  @use 'logger'
  @get /\/(.*)/, ->
    tree_id = @params[0] or 'main'

    domain = @req.header Conf.api.domain
    token  = @req.header Conf.api.token

    unless domain
      @send 400, "#{Conf.api.domain} header value required"
      return

    DB.Seed.findOne id: domain, (err, seed) =>
      switch
        when err
          @res.send 503
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
