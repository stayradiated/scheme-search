_when = require 'when'
utils = require './utils'
fs = utils.fs

# Search all the color schemes!
search = (queryColors, fn) ->

  # Convert queryColors to RGB
  queryColors = queryColors.map (hex) -> utils.toRgb(hex)

  # Load colors.json
  fs('readFile')(__dirname + '/colors.json', 'utf-8')
    .then (json) ->

      best = {}
      min = 10
      themes = JSON.parse(json)

      # Find themes with similar colors
      for filename, colors of themes
        for hex in colors
          color = utils.toRgb(hex)
          for query in queryColors
            score = utils.diff(query, color)
            continue unless score < min
            best[filename] ?= []
            best[filename].push([score, hex, utils.toHex(query)])

      # Sort themes by score
      sorted = []
      sorted.push([k, v]) for k, v of best
      sorted.sort (a, b) ->
        len_a = a[1].length
        len_b = b[1].length
        if len_a > len_b then return -1
        if len_b > len_a then return 1
        return utils.avg_dbl(a[1]) - utils.avg_dbl(b[1])

      fn(sorted)

    .otherwise (err) ->
      console.error(err)

module.exports = search

