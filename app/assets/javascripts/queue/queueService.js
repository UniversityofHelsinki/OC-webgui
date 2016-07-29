angular.module('ocWebGui.queue.service', ['ngResource', 'ocWebGui.filterpanel'])
  .factory('Queue', function ($resource, shared) {
    var teams = shared.getTeams();
    return $resource('queue.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          var queue = angular.fromJson(data);

          queue = queue.map(function (queuer) {
            queuer.created_at = new Date(queuer.created_at);
            return queuer;
          });
          return queue.filter(function (queuer) {
            return teams[queuer.team];
          });
        }
      }
    });
  });
