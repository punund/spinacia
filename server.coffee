newrelic = require 'newrelic'
_ = require 'lodash'
fs = require 'fs'
global.Conf = require('yaml-config').readConfig './config/app.yaml'

Util = require './modules/util'
DB = require './modules/database'

params = Conf.zappa_params
if Conf.https? then params.https = 
  key:  fs.readFileSync Conf.https.key
  cert: fs.readFileSync Conf.https.cert

process.umask 0o002 # group writable

unless ~~Conf.zappa_params.port
  try fs.unlinkSync Conf.zappa_params.port
  catch e

require('zappajs') params, ->

  @use 'logger'

  @get '/status', ->
    @send 200, 'OK'

  @get /\/(.*)/, ->
    tree_id = @params[0] or 'main'

    domain = @req.header Conf.api.domain
    token  = @req.header Conf.api.token

    unless domain and token
      return @send 400, "#{Conf.api.domain} and #{Conf.api.token} request headers required"

    DB.Seed.findOne id: domain, (err, seed) =>
      if err
        console.err err
        return @send 503, 'Backend error'
        
      if not seed
        return @send 404, 'No such tree in this domain'
        
      tree = (_.filter seed.trees, (tree) -> tree.id is tree_id)?[0]
      if not Util.compareTreeKey token, tree.key
        return @send 403, 'Token doesn\'t match'

      if tree.data.length > Conf.maxTreeSize
        return @send 403, 'Response is too long'

      try
        js = JSON.parse tree.data
        @json 200, js
      catch
        @send 503, 'Bad JSON'

