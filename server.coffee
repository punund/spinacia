debug = require('debug') 'spinacia:server'

global.Conf = require('yaml-config').readConfig './config/app.yaml'
Util = require './modules/util'
Api = require './modules/api'

uuid = require 'node-uuid'
spawn = require('child-process-promise').spawn
morgan = require 'morgan'
basicAuth = require 'basic-auth'
bodyParser = require 'body-parser'

REDIS_URL = process.env.REDIS_URL or 'redis://localhost'

kue = require('kue')
global.queue = kue.createQueue
   disableSearch: no
   redis: REDIS_URL

popeye = process.env.POPEYE_BINARY or Conf.popeye

queue.process 'popeye', 3, (job, done) ->
   any = (x) ->
      done null, x

   spawn popeye, [], capture: ['stdout', 'stderr']
      .then any, any, (cp) ->
         # input = job.data.input.replace /^\s*begi\w*\s/i, 'Begin Opti NoBoard '
         input = job.data.input

         cp.stdin.end input

params = port: (process.env.PORT or 5000)

require('zappajs') params, ->

   RedisStore = require('connect-redis')(@session)

   # @disable 'minify'
   @use morgan 'dev'
   # @use bodyParser.json type: Conf.contentType
   @use static: __dirname + '/public'
   @use session: secret: 'south', resave: no, saveUninitialized: no, store: new RedisStore()

   @get '/', -> @render 'index.blade'

   @get '/olive', ->  @render 'olive.blade'

   # @use @wrap ->
   #    @res.header 'Content-Type', Conf.contentType
   #    @next()

   @client '/main.js': ->
      @connect()

      @on 'disconnect', (socket) ->
         console.log 'Server is gone'

      @on solved: ->
         $('#error').hide()
         $('#solution').show().text @data.stdout

      @on queued: ->
         $('#error').hide()
         $('#solution').show().text "Queued with ID #{@data.id}, " +
            "queue size is #{@data.total}, solving..."

      @on failed: ->
         $('#solution').hide()
         $('#error').show().text @data.stderr

      @on rejected: ->
         $('#solution').hide()
         $('#error').show().text @data.errors[0].title

      $ =>
         $('#error').hide()
   
         $('#form').submit (e) =>
            $('#solution').text "Solving..."
            @emit solve:
               input: $('#input').val()
               token: '@olive'
            e.preventDefault()

   @use Util.errorWare

   @on solve: ->

      unless @data?.token?.match /@/
         @emit rejected: errors: [ title: 'Invalid token' ]
         return

      unless @data?.input.match /\sstip/i
         @emit rejected: errors: [ title: 'Need stipulation' ]
         return

      @data.id = uuid.v4()

      debug @socket.request.connection.remoteAddress

      job = Api.postTasks @data, @socket.request.connection.remoteAddress

      job.save (err) =>
         if err
            @emit rejected: errors: [ err ]
         else
            queue.activeCount (err, total) =>
               @emit queued: id: @data.id, total: total

      job.on 'complete', (result) =>
         if result.code
            @emit failed: result
         else
            @emit solved: result
