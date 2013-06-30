express = require "express"
coffee = require "connect-coffee-script"
mongo = require "mongoose"
stylus = require "stylus"
request = require "request"
FeedParser = require "feedparser"

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
  url: { type: String, unique: true }
  title: String
  link: String
  fetched: { type: Date, expires: '30m' }
  items: [
    _id: false
    title: String
    summary: String
    link: String
  ]
,
  _id: false
Feed = mongo.model "feed", feedSchema

app.get '/api/feed/:url', (req, res) ->
  url = req.params.url

  onError = (phase, error) ->
    fn = (error) ->
      res.json error: error, phase: phase, url: url

    # if called with error data, run it immediately
    if error
      fn error

    # return error function
    fn

  Feed.findOne {url: url}, {_id: 0, __v: 0}, (err, feed) ->
    if err
      onError 'mongodb', err
      return

    if feed
      res.json feed
      return

    meta = null
    items = []
    
    try
      request(url)
        .on('error', onError 'request')
        .pipe(new FeedParser normalize: true)
        .on('error', onError 'feedparser')
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
          if not meta
            onError 'results', {}
            return

          feed = new Feed
            url: url
            title: meta.title
            link: meta.link
            fetched: new Date
            items: items

          do feed.save
          res.json feed
    catch e
      onError 'pre-request', e.toString()
      throw e

app.get '/views/:view', (req, res) ->
  res.render req.params.view
app.get '/', (req, res) ->
  res.render "layout"

app.listen 8080
console.log "Listening on 8080"
