angular.module('ocWebGui.queue.service', ['ngResource', 'ocWebGui.shared.filter'])
  .factory('Queue', function ($resource, Filter) {
    var teams = Filter.getTeams();
    return $resource('queue.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          return angular.fromJson(data)
            .filter(function (queuer) {
              return teams[queuer.team];
            });
        }
      }
    });
  });
