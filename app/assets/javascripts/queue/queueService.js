angular.module('ocWebGui.queue.service', ['ngResource', 'ocWebGui.filterpanel'])
  .factory('Queue', function ($resource, shared) {
    var teams = shared.getTeams();
    return $resource('queue.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          var queue = angular.fromJson(data);
          return queue.filter(function (queuer) {
            return teams[queuer.team];
          });
        }
      }
    });
  });
