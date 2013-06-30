angular.module('feedblocks')
.controller 'Main', ($scope, $timeout, Feed) ->
  $scope.feeds = []
  $scope.popular = [
    title:"Rock, Paper, Shotgun"
    link:"http://feeds.feedburner.com/RockPaperShotgun"
  ,
    title:"Ars Technica"
    link:"http://feeds.arstechnica.com/arstechnica/index"
  ,
    title:"Error test"
    link:"http://localhost:9999/doesnotexist"
  ,
    title: "Local test",
    link: "http://localhost:8080/testrss.xml"
  ]

  $scope.AddFeed = ->
    $scope.AddFeedUrl $scope.feedSearch
    $scope.feedSearch = ""

  $scope.AddFeedUrl = (url) ->
    $scope.feedLoading = true
    Feed.get url: url, (feed) ->
      if feed.error
        $scope.feedError = "Could not fetch feed"
      else
        $scope.feeds.push feed
      $scope.feedLoading = false

