
express = require 'express'
fs = require 'fs'
ImageParser = require './imageParse'
Search = require './search'

app = express()

app.configure ->
  app.use express.static('public')
  app.use express.bodyParser()

  # Allow CORS
  app.all "/*", (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "X-Requested-With"
    next()

app.post '/upload', (req, res) ->
  coords = JSON.parse(req.body.coords[0])
  path = req.files?.image[0]?.path
  stream = fs.createReadStream(path)
  ImageParser stream, coords, (err, data) -> res.send(data)

app.post '/search', (req, res) ->
  queryColors = JSON.parse(req.body.query)
  Search queryColors, (results) ->
    res.setHeader('Content-Type', 'application/json')
    res.send JSON.stringify(results)

app.listen(1337)
