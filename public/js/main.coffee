angular.module('feedblocks', ['ngResource'])
.config ($locationProvider, $routeProvider) ->
    $locationProvider.html5Mode true

    $routeProvider
        .when('/',
            templateUrl: '/views/index'
            controller: 'Index'
        )
        .when('/feed/:url',
            templateUrl: '/views/feed'
            controller: 'Feed'
            resolve: feed: ($route, Feed) ->
                Feed.get $route.current.params
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
.controller 'Feed', ($scope, $route) ->
    $scope.feed = $route.current.locals.feed
