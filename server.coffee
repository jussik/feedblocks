express = require "express"
coffee = require "connect-coffee-script"
mongo = require "mongoose"
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

mongo.connect "mongodb://localhost/feedblocks"
mongo.connection.on 'error', (err) ->
  console.error 'Mongo error', err

feedSchema = mongo.Schema
  url: String
  title: String
  link: String
  fetched: { type: Date, expires: '30m' }
  items: [
    title: String
    summary: String
    link: String
  ]
Feed = mongo.model "feed", feedSchema

app.get '/api/feed/:url', (req, res) ->
  url = req.params.url

  Feed.find url: url, (err, feeds) ->
    onError = (err) ->
      res.json error: err, url: url

    if err
      onError err
      return

    if feeds.length
      res.json feeds[0]
      return

    meta = null
    items = []

    request(url)
      .on('error', onError)
      .pipe(new feed normalize: true)
      .on('error', onError)
      .on 'meta', (m) ->
        meta = m
      .on 'readable', ->
        while item = do @read
          items.push
            title: item.title
            summary: item.summary
            link: item.link
        return # do not return while expression
      .on 'end', ->
        feed = new Feed
          url: url
          title: meta.title
          link: meta.link
          fetched: new Date
          items: items

        do feed.save
        res.json feed

app.get '/views/:view', (req, res) ->
  res.render req.params.view
app.get '/', (req, res) ->
  res.render "layout"

app.listen 8080
console.log "Listening on 8080"
