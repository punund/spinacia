mongoose = require 'mongoose'

keepAlive = keepAlive: 1
options =
  server:
    auto_reconnect: on
    socketOptions: keepAlive
    replset: keepAlive

mongolog = (m) -> console.log("*** MongoDB #{m} ***")

db = mongoose.connect Conf.mongodb.uri, options

connection = mongoose.connection
connection.on 'connected', -> mongolog 'connected'
connection.on 'close', -> mongolog 'closed'
connection.on 'reconnected', -> mongolog 'reconnected'
connection.on 'disconnected', -> mongolog 'disconnected'
connection.on 'error', (error) ->
  mongolog 'error: ' + error


Seed = db.model 'Seed', mongoose.Schema
  id:
    type: String
    match: /^[a-z0-9]+[a-z0-9|\-]+[a-z0-9]+$/
    unique: yes
  trees: [
    id:
      type: String
      match: /^[a-z0-9]+[a-z0-9|\-]+[a-z0-9]+$/
      #TODO: check if it works
      # unique: yes
    data:
      type: String
    key:
      type: Buffer
  ]
  defaultTree:
    type: String
    required: no
  data:
    type: String

module.exports = {Seed}
