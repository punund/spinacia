debug = require('debug') 'configly-api:server'
newrelic = require 'newrelic'
basicAuth = require 'basic-auth'
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
    @send 200, "OK\n"

  @get /\/(.*)/, ->

    auth = basicAuth @req
    if not auth
      return @send 401, "Authentication required\n"

    domain = auth.name
    token  = auth.pass

    DB.Seed.findOne id: domain, (err, seed) =>
      if err
        console.error err
        return @send 503, "Backend error\n"
        
      if not seed
        return @send 403, "Authentication failure\n"

      tree_id = @params[0] or seed.defaultTree or 'main'
        
      tree = (_.filter seed.trees, (tree) -> tree.id is tree_id)?[0]

      if not tree
        return @send 403, "Authentication failure\n"

      if not Util.compareTreeKey token, tree.key
        return @send 403, "Authentication failure\n"

      if not tree.data
        return @json 200, {}

      if tree.data.length > Conf.maxTreeSize
        return @send 403, "Response is too long\n"

      try
        js = JSON.parse tree.data
        @json 200, js
      catch
        @send 503, "Bad JSON\n"

