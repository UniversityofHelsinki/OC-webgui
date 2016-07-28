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
          if (angular.isDefined(dateobj)) {
            var time = CustomDate.getDate().getTime() - dateobj.getTime();
            currentSeconds = Math.round(time / 1000);
          }
          var seconds = currentSeconds % 60;
          var minutes = Math.floor(currentSeconds / 60);

          if (minutes > 60) {
            var minutes = Math.floor(currentSeconds / 60 % 60);
            var hours = Math.floor(currentSeconds / 60 / 60);
            element.text(pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds));
          } else {
            element.text(pad2(minutes) + ':' + pad2(seconds));
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
