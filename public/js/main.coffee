angular.module('feedblocks', ['ngResource'])
.config ($locationProvider, $routeProvider) ->
    $locationProvider.html5Mode true

    $routeProvider
        .when('/',
            templateUrl: '/views/index'
            controller: 'Index'
        )
        .otherwise(templateUrl: '/views/error')

.factory 'Feed', ($resource) ->
    $resource '/api/feed/:url'

.controller 'Index', ($scope, Feed) ->
    $scope.feeds = []
    $scope.popular = [
        {title:"Rock, Paper, Shotgun",link:"http://feeds.feedburner.com/RockPaperShotgun"}
    ]
    $scope.AddFeed = (url) ->
        $scope.feeds.push(Feed.get url: url)
