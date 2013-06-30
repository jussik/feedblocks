angular.module('feedblocks', ['ngResource'])
.config ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode true

  $routeProvider
    .when('/',
      templateUrl: '/views/main'
      controller: 'Main'
    )
    .otherwise(templateUrl: '/views/error')

.factory 'Feed', ($resource) ->
  $resource '/api/feed/:url'
