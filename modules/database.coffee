mongoose = require 'mongoose'
options =
  server:
    socketOptions: { keepAlive: 1 }
  replset:
    socketOptions: { keepAlive: 1 }

db = mongoose.connect Conf.mongodb.uri, options, (err) ->
  console.log '!!! mongoose connect error: ', err if err


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
