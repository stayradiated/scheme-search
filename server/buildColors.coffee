
###*
 * @fileOverview Converts .tmTheme into .colors
###

_when = require 'when'
utils = require './utils'
fs = utils.fs


files = []
colors = {}

# Load all .tmTheme files
loadThemes = (_files) ->

  files = _files

  promises = (
    for filename in files
      fs('readFile')("themes/#{ filename }", 'utf-8')
  )

  _when.all(promises).then(convertThemes)


# Extract hex codes from each themem
convertThemes = (themes) ->

  colors = {}

  # Extract hex codes
  for theme, index in themes

    filename = files[index]
    array = colors[filename] = []
    hexCodes = theme.match(/#[0-9a-f]{6}/gi)

    continue unless hexCodes?

    for code in hexCodes
      array.push(code) if array.indexOf(code) < 0

  # # Convert hex codes into RGB
  # for filename, val of colors

  #   rgb = (utils.toRgb(hex) for hex in val)
  #   colors[filename] = rgb

  # Generate colors.json
  json = JSON.stringify(colors)
  fs('writeFile')(__dirname + '/colors.json', json)

# Start process by reading all files in themes directory
fs('readdir')('themes').then(loadThemes)
