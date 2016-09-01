angular.module('ocWebGui.screens.queue.service', ['ngResource', 'ocWebGui.shared.filter'])
  .factory('Queue', function ($q, $http, Filter) {
    return {
      query: function () {
        return $q.all({
          teams: Filter.getTeams(),
          queue: $http.get('api/queue')
        }).then(function (values) {
          return values.queue.data
            .map(function (queuer) {
              queuer.created_at = new Date(queuer.created_at);
              return queuer;
            })
            .filter(function (queuer) {
              return values.teams[queuer.team];
            });
        });
      }
    };
  });
