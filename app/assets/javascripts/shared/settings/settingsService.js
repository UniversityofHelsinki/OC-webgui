angular.module('ocWebGui.shared.settings', [])
  .factory('Settings', function ($rootScope, $log) {
    var settings = {
      colors: {
        background: '#87aade',
        font: '#333333',
        statuses: {
          free: '#37c837',
          call: '#ffff4d',
          busy: '#ff3333'
        }
      }
    };
    return {
      getColors: function () {
        return angular.copy(settings.colors);
      },
      getColor: function (colorName) {
        var color = settings.colors;
        for (var i = 0, path = colorName.split('.'); i < path.length; i++) {
          if (!color[path[i]]) {
            $log.error('Invalid color: ' + colorName);
            return 'red';
          }
          color = color[path[i]];
        }
        return color;
      },
      setColors: function (colors) {
        settings.colors = angular.copy(colors);
        $rootScope.$broadcast('settings:colors:update');
      }
    };
  });
