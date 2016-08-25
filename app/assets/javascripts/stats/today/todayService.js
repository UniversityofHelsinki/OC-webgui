angular.module('ocWebGui.stats.today.service', ['ngResource'])
  .factory('Stats', function ($q, $http, Settings) {
    return {
      query: function () {
        return $q.all({
          otherSettings: Settings.getOthers(),
          response: $http.get('api/contacts/stats')
        }).then(function (values) {
          return values;
        });
      }
    };
  });
