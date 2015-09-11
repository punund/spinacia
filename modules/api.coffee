debug = require('debug') 'spinacia:api'
clc = require 'cli-color'

Util = require '../modules/util'

exports =

    postTasks: (data, id) ->
      debug data
      console.log data
      console.log data.input
      id ?= 'direct'
      input = data.input
      job = queue.create 'popeye',
         title: Util.stipulation input
         input: input
         id: id
      .priority Util.stip2priority input

module.exports = exports

