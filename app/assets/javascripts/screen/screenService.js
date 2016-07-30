angular.module('ocWebGui.screen.service', ['ngResource', 'ocWebGui.filterpanel'])
  .factory('Agents', function ($resource, shared) {
    var teams = shared.getTeams();
    var states = shared.getStates();
    return $resource('agent_statuses.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          return angular.fromJson(data)
            .filter(function (agent) {
              return teams[agent.team.name] && (states[agent.status] || (states.Muut && !(agent.status in states)));
            })
            .map(function (agent) {
              agent.created_at = new Date(agent.created_at);

              switch (agent.status) {
                case 'Vapaa':
                  agent.color = 'free';
                  break;
                case 'Jälkikirjaus':
                case 'Puhelu':
                  agent.color = 'call';
                  break;
                default:
                  agent.color = 'busy';
                  break;
              }

              return agent;
            });
        }
      }
    });
  });
