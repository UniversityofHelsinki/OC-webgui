angular.module('ocWebGui.screen.service', ['ngResource', 'ocWebGui.filterpanel'])
  .factory('Agents', function ($resource, shared) {
    var teams = shared.getTeams();
    var states = shared.getStates();
    return $resource('agents.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          var agents = angular.fromJson(data);
          return agents.filter(function (agent) {
            return states[agent.status] && teams[agent.team];
          });
        }
      }
    });
  });