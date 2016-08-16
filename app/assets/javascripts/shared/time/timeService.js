angular.module('ocWebGui.shared.time.service', [])
  .factory('CustomDate', function () {
    return {
      getDate: function () {
        return new Date();
      },

      niceFormatting: function (currentSeconds) {
        var pad2 = function (value) {
          return (value < 10 ? '0' : '') + value;
        };
        var seconds = Math.floor(currentSeconds % 60);
        var minutes = Math.floor(currentSeconds / 60);

        if (minutes > 60) {
          minutes = Math.floor(currentSeconds / 60 % 60);
          var hours = Math.floor(currentSeconds / 60 / 60);
          return pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds);
        }

        return pad2(minutes) + ':' + pad2(seconds);
      }
    };
  });
