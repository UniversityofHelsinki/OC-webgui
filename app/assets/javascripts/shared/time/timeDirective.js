angular.module('ocWebGui.shared.time', [])
  .directive('ocTime', function ($interval) {
    return {
      restrict: 'E',
      scope: {
        seconds: '=',
        update: '='
      },
      link: function (scope, element) {
        var currentSeconds = scope.seconds;

        function pad2(value) {
          return (value < 10 ? '0' : '') + value;
        }

        function updateTime() {
          var seconds = currentSeconds % 60;
          var minutes = Math.floor(currentSeconds / 60);
          element.text(pad2(minutes) + ':' + pad2(seconds));
        }

        scope.$watch('seconds', function (value) {
          currentSeconds = value;
          updateTime();
        });

        if (scope.update) {
          var timeoutId = $interval(function () {
            currentSeconds++;
            updateTime();
          }, 1000);

          element.on('$destroy', function () {
            $interval.cancel(timeoutId);
          });
        }

        updateTime();
      }
    };
  });
