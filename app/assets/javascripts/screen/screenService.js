angular.module('ocWebGui.screen.service', ['ngResource', 'ocWebGui.shared.filter'])
  .factory('Agents', function ($resource, Filter) {
    var teams = Filter.getTeams();
    var states = Filter.getStates();
    return $resource('agent_statuses.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          return angular.fromJson(data)
            .filter(function (agent) {
              return teams[agent.team.name] && (states[agent.status] ||
                  (states.Muut && !(agent.status in states)));
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
