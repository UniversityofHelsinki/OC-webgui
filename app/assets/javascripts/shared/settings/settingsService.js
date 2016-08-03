angular.module('ocWebGui.shared.settings', [])
  .factory('Settings', function ($rootScope, $log, $http, $q) {
    var getSettingsPromise;
    var settingsCache;

    function fetchSettings() {
      if (getSettingsPromise) {
        return getSettingsPromise;
      }
      if (settingsCache) {
        return $q.resolve(settingsCache);
      }
      getSettingsPromise = $http.get('settings.json').then(function (response) {
        settingsCache = response.data;
        getSettingsPromise = undefined;
        return settingsCache;
      });
      return getSettingsPromise;
    }

    function postSettings(settings) {
      return $http.post('settings.json', settings).then(function () {
        settingsCache = angular.copy(settings);
        return settingsCache;
      });
    }

    return {
      getColors: function () {
        return fetchSettings().then(function (settings) {
          return angular.copy(settings.colors);
        });
      },
      getColor: function (colorName) {
        return fetchSettings().then(function (settings) {
          var color = settings.colors;
          for (var i = 0, path = colorName.split('.'); i < path.length; i++) {
            if (!color[path[i]]) {
              $log.error('Invalid color: ' + colorName);
              return 'red';
            }
            color = color[path[i]];
          }
          return color;
        });
      },
      setColors: function (colors) {
        return fetchSettings().then(function (settings) {
          return postSettings(angular.extend({}, settings, { colors: colors }));
        }).then(function () {
          $rootScope.$broadcast('settings:colors:update');
        });
      },
      getOthers: function () {
        return fetchSettings().then(function (settings) {
          return angular.copy(settings.others);
        });
      },
      setOthers: function (others) {
        return fetchSettings().then(function (settings) {
          return postSettings(angular.extend({}, settings, { others: others }));
        }).then(function () {
          $rootScope.$broadcast('settings:others:update');
        });
      },
      invalidateCache: function () {
        getSettingsPromise = undefined;
        settingsCache = undefined;
        $rootScope.$broadcast('settings:colors:update');
        $rootScope.$broadcast('settings:others:update');
      }
    };
  });
