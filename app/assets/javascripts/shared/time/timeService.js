angular.module('ocWebGui.shared.time.service', [])
  .factory('CustomDate', function () {
    return {
      getDate: function () {
        return new Date();
      },

      secondsToHoursMinutesSeconds: function (currentSeconds) {
        var seconds = currentSeconds % 60;
        var minutes = Math.floor(currentSeconds / 60);

        pad2 = function (value) {
          return (value < 10 ? '0' : '') + value;
        };

        if (minutes >= 60) {
          minutes = Math.floor(currentSeconds / 60 % 60);
          var hours = Math.floor(currentSeconds / 60 / 60);
          return pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds);
        }

        return pad2(minutes) + ':' + pad2(seconds);
      }
    };
  });
