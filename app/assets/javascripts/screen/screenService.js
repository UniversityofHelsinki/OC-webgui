angular.module('ocWebGui.screen.service', ['ngResource', 'ocWebGui.filterpanel'])
  .factory('Agents', function ($resource, shared) {
    var teams = shared.getTeams();
    var states = shared.getStates();
    return $resource('agent_statuses.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          var agents = angular.fromJson(data);
          agents = agents.map(function (agent) {
            agent.created_at = new Date(agent.created_at);
            switch (agent.status) {
                  case 'Vapaa':
                      agent.color = 'green';
                      break;
                  case 'Jälkikirjaus':
                  case 'Puhelu':
                      agent.color = 'yellow';
                      break;
                  default:
                      agent.color = 'red';
                      break;
            }
              
            return agent;
          });
          return agents.filter(function (agent) {
            return teams[agent.team.name] && (states[agent.status] || (states.Muut && !(agent.status in states)));
          });
        }
      }
    });
  });
