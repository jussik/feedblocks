angular.module('feedblocks')
.directive 'checkedClick', ($parse) ->
  (scope, elem, attr) ->
    fn = $parse attr.fbClick
    elem.on 'click', (event) ->
      if not elem.is '.disabled'
        scope.$apply(-> fn scope, $event: event)
