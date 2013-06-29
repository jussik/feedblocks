express = require "express"
coffee = require "connect-coffee-script"
stylus = require "stylus"
feed = require "feedparser"
request = require "request"

app = express()
pub = __dirname + "/public"

app.set "views", "views"
app.set "view engine", "jade"

app.use coffee src: pub, sourceMap: true
app.use stylus.middleware src: pub, dest: pub
app.use express.static pub

app.get '/api/feed/:url', (req, res) ->
  meta = null
  items = []
  request(req.params.url)
    .pipe(new feed normalize: true)
    .on 'error', (err) ->
      res.json error: err
    .on 'meta', (m) ->
      meta = m
    .on 'readable', () ->
      while item = do @read
        items.push
          title: item.title
          summary: item.summary
          link: item.link
          _item: item
      return # do not return while expression
    .on 'end', ->
      res.json
        title: meta.title
        link: meta.link
        items: items
        _meta: meta

app.get '/views/:view', (req, res) ->
  res.render req.params.view
app.get '/', (req, res) ->
  res.render "layout"

app.listen 8080
console.log "Listening on 8080"
