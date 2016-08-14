angular.module('ocWebGui.screens.queue.service', ['ngResource', 'ocWebGui.shared.filter'])
  .factory('Queue', function ($q, $http, Filter) {
    return {
      query: function () {
        return $q.all({
          teams: Filter.getTeams(),
          queue: $http.get('queue.json')
        }).then(function (values) {
          return values.queue.data
            .filter(function (queuer) {
              return values.teams[queuer.team];
            });
        });
      }
    };
  });
