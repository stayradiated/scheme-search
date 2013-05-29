_fs = require 'fs'
_when = require 'when'
utils = require './utils'

# A simple promise wrapper for Node FS
fs = (method) ->
  return (args...) ->
    deferred = _when.defer()
    args.push (err, data) ->
      if err? then return deferred.reject(err)
      deferred.resolve(data)
    _fs[method](args...)
    return deferred.promise

# Search all the color schemes!
search = (queryColors, fn) ->

  # Convert queryColors to RGB
  queryColors = queryColors.map (hex) -> utils.toRgb(hex)

  # Load colors.json
  fs('readFile')(__dirname + '/colors.json', 'utf-8')
    .then (json) ->

      best = {}
      min = 5
      themes = JSON.parse(json)

      # Find themes with similar colors
      for filename, colors of themes
        for color in colors
          for query in queryColors
            score = utils.diff(query, color)
            continue unless score < min
            best[filename] ?= []
            best[filename].push(score)

      # Sort themes by score
      sorted = []
      sorted.push([k, v]) for k, v of best
      sorted.sort (a, b) ->
        len_a = a[1].length
        len_b = b[1].length
        if len_a > len_b then return -1
        if len_b > len_a then return 1
        return utils.avg(a[1]) - utils.avg(b[1])

      fn(sorted[0...10])

    .otherwise (err) ->
      console.error(err)

module.exports = search

