crypto = require 'crypto'

treeKey = new Buffer Conf.key.tree, 'hex'

finalize = (xcipher, what) ->
  try
    Buffer.concat [
      xcipher.update what, 'ascii'
      xcipher.final()
      ]
  catch error
    console.error '+++ crypto error: ' + error
    null

generalEncrypt = (secret, what) ->
  cipher = crypto.createCipher 'aes-256-cbc', secret
  finalize cipher, what

exports =

  compareTreeKey: (input, stored) ->
    generalEncrypt(treeKey, input)?.toString('hex') is stored?.toString('hex')

module.exports = exports
