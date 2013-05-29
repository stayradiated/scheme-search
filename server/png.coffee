PNG = require('pngjs').PNG
utils = require './utils'

# Returns the top ten most used colors in a PNG file
getColors = (coords, fn) ->

  return ->

    colors = {}

    coords.x ?= 0
    coords.y ?= 0
    coords.x2 ?= @width
    coords.y2 ?= @height

    console.log 'Using coords', coords
    console.log 'Width', @width
    console.log 'Height', @height

    # Collect hex codes
    for y in [coords.y...coords.y2] by 1
      for x in [coords.x...coords.x2] by 1
        idx = @width * y + x << 2
        rgb = [@data[idx], @data[idx+1], @data[idx+2]]
        hex = utils.toHex(rgb)
        colors[hex] ?= 0
        colors[hex] += 1

    # Sort colors by amount
    sorted = []
    sorted.push [k, v] for k, v of colors
    sorted.sort (a, b) -> b[1] - a[1]

    # Extract hex codes only
    hex = sorted.map (x) -> x[0]

    # Send hex codes to client
    fn(null, JSON.stringify(hex[0..10]))


# Pipes stream into the getColors method
module.exports = (stream, coords, fn) ->
  png = new PNG( filterType: -1 )
  stream.pipe(png).on('parsed', getColors(coords, fn))