debug = require('debug') 'configly-api:server'
newrelic = require 'newrelic'
basicAuth = require 'basic-auth'
_ = require 'lodash'
fs = require 'fs'
morgan = require 'morgan'
xmlbuilder = require 'xmlbuilder'
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

  @use morgan 'combined'

  @get '/status', ->
    @send 200, "OK\n"

  @get /\/(\w*)\.?(\w*)?/, ->

    auth = basicAuth @req
    if not auth
      @res.set 'WWW-Authenticate', 'Basic realm="Configly API"'
      return @send 401, "Authentication required\n"

    domain = auth.name
    token  = auth.pass

    # format = @params[1] or 'json'
    debug @req.header 'accept'

    accepts = @req.accepts('json, html, xml')
    # if not accepts
    #   return @send 406, "We serve JSON or XML\n"

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
        @res.jsonp {}

      if tree.data.length > Conf.maxTreeSize
        return @send 403, "Response is too long\n"

      js = null
      try
        js = JSON.parse tree.data
      catch err
        console.error err
        return @status(503).send "Bad JSON\n"


      if accepts isnt 'xml' # json, html
        @res.jsonp js
      else
        try
          root = xmlbuilder.create('root', encoding: 'UTF-8').ele(js)
          xml = root.end(pretty: yes)

          @res.set 'Content-Type', 'application/xml'
          @send xml
        catch err
          console.error err
          @status(503).send "Error preparing XML\n"
