angular.module('ocWebGui.shared.color', [])
  .directive('ocColor', function (Settings) {
    return {
      restrict: 'A',
      scope: {
        ocColor: '@'
      },
      link: function (scope, element) {
        function updateColor() {
          element.css('background-color', Settings.getColor(scope.ocColor));
        }
        scope.$watch('ocColor', updateColor);
        scope.$on('settings:colors:update', updateColor);
        updateColor();
      }
    };
  });
