# Uint8Array - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays/Uint8Array
Binary = require "./namespace"
Utf8 = require   "./utf8"
Types = require  '../types'
{inspect} = require '../inspect'
{isString, isFunction} = Types
{readFileAsDataUrl} = require '../promised_file_reader'

encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

Binary.binary = (arg) ->
  if arg instanceof BinaryString
    arg
  else
    new BinaryString arg

module.exports = class BinaryString
  @binary = Binary.binary

  @cloneUint8Array: (srcU8A) ->
    dstU8A = new Uint8Array new ArrayBuffer src.length
    dstU8A.set srcU8A
    dstU8A

  constructor: (arg) ->
    @bytes = if arg instanceof BinaryString   then BinaryString.cloneUint8Array(arg.bytes)
    else if isFunction arg?.uint8Array        then arg.uint8Array()
    else if arg instanceof ArrayBuffer        then new Uint8Array arg
    else if arg instanceof Uint8Array         then arg
    else if isString arg                      then Utf8.toBuffer arg
    else throw new Error "invalid Binary string constructor argument: #{inspect arg}"
    @length = @bytes.length

  @fromBase64: (base64encoding)->
    byteString = atob base64encoding

    len = byteString.length
    uInt8Array = new Uint8Array new ArrayBuffer len

    for i in [0...len] by 1
      uInt8Array[i] = byteString.charCodeAt i

    new BinaryString uInt8Array

  toDataUri: (callback) ->
    throw new Error "BinaryString.toImage: callback is no longer supported; use returned Promise" if callback
    readFileAsDataUrl new Blob [@bytes]

  @fromDataUri: (dataURI)->
    splitDataURI = dataURI.split ','
    base64encoding = splitDataURI[1]
    @fromBase64 base64encoding

  toString: ->
    Utf8.toString @bytes

  toArrayBuffer: ->
    @bytes.buffer

  toBlob: ->
    new Blob [@bytes]

  ###
  toBase64 performance
  see: http://localhost:8080/webpack-dev-server/perf?grep=BinaryString
  as-of 2016-02-14, the manual string manipulation version is surprisingly the best on average for FF, Chrome and Safari
    For shorter lengths, toBase64Custom is by far the fastest, but
    toBase64ToDataUri starts to be faster at longer lengths.
  ###
  toBase64: ->
    # 2016-2-14 benchmark based results for cut-over-to-toBase64ToDataUri length
    # FF:                 4 * 1024
    # Safari and Chrome:  16 * 1024
    if @length > 16 * 1024
      @toBase64ToDataUri()
    else
      @toBase64Custom()

  # surprizing to me, but as-of 2016-02-14 this one is always the slowest AND it crashs if the string is >= 128k
  # toBase64Btoa: ->
  #   Promise.resolve btoa String.fromCharCode.apply null, Array.prototype.slice.call @bytes

  toBase64ToDataUri: ->
    @toDataUri()
    .then (dataUri) -> dataUri.split(',')[1]

  toBase64Custom: ->
    # src: https:#gist.github.com/jonleighton/958841
    bytes = @bytes

    # buffer = new Uint8Array(buffer) if buffer instanceof ArrayBuffer
    base64    = ''

    byteLength    = bytes.byteLength
    byteRemainder = byteLength % 3
    mainLength    = byteLength - byteRemainder

    # Main loop deals with bytes in chunks of 3
    for i in [0..mainLength-1] by 3
      # Combine the three bytes into a single integer
      chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]

      # Use bitmasks to extract 6-bit segments from the triplet
      a = (chunk & 16515072) >> 18 # 16515072 = (2^6 - 1) << 18
      b = (chunk & 258048)   >> 12 # 258048   = (2^6 - 1) << 12
      c = (chunk & 4032)     >>  6 # 4032     = (2^6 - 1) << 6
      d = chunk & 63               # 63       = 2^6 - 1

      # Convert the raw binary segments to the appropriate ASCII encoding
      base64 += encodings[a] + encodings[b] + encodings[c] + encodings[d]

    # Deal with the remaining bytes and padding
    Promise.resolve switch byteRemainder
      when 0 then base64
      when 1
        chunk = bytes[mainLength]

        a = (chunk & 252) >> 2 # 252 = (2^6 - 1) << 2

        # Set the 4 least significant bits to zero
        b = (chunk & 3)   << 4 # 3   = 2^2 - 1

        base64 + encodings[a] + encodings[b] + '=='

      when 2
        chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]

        a = (chunk & 64512) >> 10 # 64512 = (2^6 - 1) << 10
        b = (chunk & 1008)  >>  4 # 1008  = (2^6 - 1) << 4

        # Set the 2 least significant bits to zero
        c = (chunk & 15)    <<  2 # 15    = 2^4 - 1

        base64 + encodings[a] + encodings[b] + encodings[c] + '='