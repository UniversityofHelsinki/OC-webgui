angular.module('ocWebGui.shared.time', [])
  .directive('ocTime', function ($interval) {
    return {
      restrict: 'E',
      scope: {
        seconds: '=',
        dateobj: '='
      },
     link: function (scope, element) {
        var currentSeconds = scope.seconds;
        var dateobj = scope.dateobj;

        function pad2(value) {
          return (value < 10 ? '0' : '') + value;
        }

        function updateTime() {
          var seconds = currentSeconds % 60;
          var minutes = Math.floor(currentSeconds / 60);
          element.text(pad2(minutes) + ':' + pad2(seconds));
        }

        scope.$watchGroup(['seconds', 'dateobj'], function(values) {
          console.log(values);
          if (values[1] != null) {
            var seconds = Math.round(new Date().getTime() / 1000) - Math.round(values[1].getTime() / 1000);
            currentSeconds = seconds;
          } else if (values[0] != null) {
            currentSeconds = values[0];
          }
          updateTime();
        });

        var timeoutId = $interval(function () {
          currentSeconds++;
          updateTime();
        }, 1000);

        element.on('$destroy', function () {
          $interval.cancel(timeoutId);
        });

        updateTime();
      }
    };
  });
