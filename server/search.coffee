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
      min = 5
      themes = JSON.parse(json)

      # Find themes with similar colors
      for filename, colors of themes
        for color in colors
          color = utils.toRgb(color)
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

