angular.module('ocWebGui.screens.status.service', ['ngResource', 'ocWebGui.shared.filter'])
  .factory('Agents', function ($q, $http, Filter) {
    return {
      query: function () {
        return $q.all({
          teams: Filter.getTeams(),
          states: Filter.getStates(),
          agents: $http.get('api/agent_statuses')
        }).then(function (values) {
          return values.agents.data
            .filter(function (agent) {
              return values.teams[agent.team.name] && (values.states[agent.status] ||
                  (values.states.Muut && !(agent.status in values.states)));
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
        });
      }
    };
  });
