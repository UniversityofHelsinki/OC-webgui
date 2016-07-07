angular.module('ocWebGui.shared.time', ['ocWebGui.shared.time.service'])
  .directive('ocTime', function ($interval, CustomDate) {
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

        scope.$watchGroup(['seconds', 'dateobj'], function (values) {
          if (values[0] != null) {
            // use seconds
            currentSeconds = values[0];
          } else if (values[1] != null) {
            // use dateobj
            var dateFromFactor = CustomDate.getDate();
            var seconds = Math.round((dateFromFactor.getTime() - values[1].getTime()) / 1000);
            currentSeconds = seconds;
          }
          updateTime();
        });

        if (angular.isDefined(dateobj)) {
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
