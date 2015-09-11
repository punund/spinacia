debug = require('debug') 'configly-api:util'
clc = require 'cli-color'

exports =

   stip2priority: (inp) ->
      r = inp.match /stip\w*\s+\w+\W+(\d+\.?5?)\W/i
      return 100 unless r?[1]
      numOfMoves = r[1]
      numOfMoves * 10 or 100

   stipulation: (inp) ->
      r = inp.match /stip\w*\s+\w+(\S+\d)\W/i or ''

   errorWare: (err, req, res, next) ->
      if err.match and m = err.match /^(\d+) (.+)$/
         status = m[1]
         text = m[2]
      else
         status = 500
         text = 'Processing error'

      console.error clc.xterm(1)('✳ ') + err
      res.status(status).json errors: title: text

      # switch
      #    when err instanceof Array
      #       err = new Failure err[1], err[0]
      #    when err.match and m = err.match /^(\d+) (.+)$/
      #       err = new Failure m[2], m[1]
      # u.error err
      # status = err.status or 500
      # if err not instanceof Failure
      #    err.message = 'Something horrible happened'
      # if req.ajax
      #    res.sendMess status, {}, (err.message or err)
      # else
      #    res.status(status).render 'error.blade',
      #       message: err.toString()
      #       error: err


module.exports = exports
