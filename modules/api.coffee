debug = require('debug') 'spinacia:api'
clc = require 'cli-color'

Util = require '../modules/util'

exports =

    postTasks: (data, ip) ->
      id = data.id
      input = data.input
      title = Util.stipulation input
      debug title
      console.log '>>> SOLVE ' + clc.xterm(82)(title) + ' ' + ip
      job = queue.create 'popeye', {title, input, id}
      .priority Util.stip2priority input
      .removeOnComplete yes

module.exports = exports

