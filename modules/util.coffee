debug = require('debug') 'configly-api:util'
clc = require 'cli-color'

exports =

   stip2priority: (inp) ->
      r = inp.match /stip\w*\s+\w+\W+(\d+\.?5?)\W/i
      return 100 unless r?[1]
      numOfMoves = r[1]
      numOfMoves * 10 or 100

   stipulation: (inp) ->
      r = inp.match /stip\w*\s+(\S+)\W/i
      r?[1] or ''

   errorWare: (err, req, res, next) ->
      if err.match and m = err.match /^(\d+) (.+)$/
         status = m[1]
         text = m[2]
      else
         status = 500
         text = 'Processing error'

      console.error clc.xterm(1)('✳ ') + err
      res.status(status).json errors: title: text

module.exports = exports
