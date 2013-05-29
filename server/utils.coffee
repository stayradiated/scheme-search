
_fs = require 'fs'
_when = require 'when'

module.exports =

  # Convert HEX to RGB
  toRgb: (hex) ->
    r = parseInt(hex[1..2], 16)
    g = parseInt(hex[3..4], 16)
    b = parseInt(hex[5..6], 16)
    return [r, g, b]

  # Convert RGB to HEX
  toHex: (rgb) ->
    r = rgb[0].toString(16)
    if r.length < 2 then r = '0' + r
    g = rgb[1].toString(16)
    if g.length < 2 then g = '0' + g
    b = rgb[2].toString(16)
    if b.length < 2 then b = '0' + b
    return '#' + r + g + b

  # Get the difference between two RGB arrays
  diff: (a, b) ->
    arr = [
      Math.abs(a[0] - b[0])
      Math.abs(a[1] - b[1])
      Math.abs(a[2] - b[2])
    ]
    return @avg(arr)

  # Get the average value of an array
  avg: (arr) ->
    out = 0
    out += num for num in arr
    out /= arr.length
    return out

  # Get the average value of the first value of an array inside an array
  avg_dbl: (arr) ->
    console.log arr
    out = 0
    out += num[0] for num in arr
    out /= arr.length
    return out

  # A simple promise wrapper for Node FS
  fs: (method) ->
    return (args...) ->
      deferred = _when.defer()
      args.push (err, data) ->
        if err? then return deferred.reject(err)
        deferred.resolve(data)
      _fs[method](args...)
      return deferred.promise
