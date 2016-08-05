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

        function updateTime() {
          if (angular.isDefined(dateobj)) {
            var time = CustomDate.getDate().getTime() - dateobj.getTime();
            currentSeconds = Math.round(time / 1000);
            element.text(CustomDate.secondsToHoursMinutesSeconds(currentSeconds));
          }
        }

        scope.$watchGroup(['seconds', 'dateobj'], function (values) {
          if (values[0] != null) {
            // use seconds
            currentSeconds = values[0];
          } else if (values[1] != null) {
            // use dateobj
            dateobj = values[1];
          } else {
            currentSeconds = 0;
          }
          updateTime();
        });

        if (angular.isDefined(dateobj)) {
          var timeoutId = $interval(updateTime, 1000);
          element.on('$destroy', function () {
            $interval.cancel(timeoutId);
          });
        }

        updateTime();
      }
    };
  });
