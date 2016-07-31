angular.module('ocWebGui.shared.color', [])
  .directive('ocColor', function (Settings) {
    return {
      restrict: 'A',
      scope: {
        ocColor: '@'
      },
      link: function (scope, element) {
        function updateColor() {
          Settings.getColor(scope.ocColor).then(function (color) {
            element.css('background-color', color);
          });
        }
        scope.$watch('ocColor', updateColor);
        scope.$on('settings:colors:update', updateColor);
        updateColor();
      }
    };
  });
