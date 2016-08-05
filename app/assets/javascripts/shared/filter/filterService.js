angular.module('ocWebGui.shared.filter', ['ngResource'])
  .factory('Filter', function ($http) {
    var teams;
    var states;

    return {
      getTeams: function () {
        return $http.get('teams.json', { cache: true }).then(function (response) {
          if (teams) {
            return teams;
          }
          teams = {};
          response.data.forEach(function (team) {
            teams[team.name] = team.filter;
          });
          return teams;
        });
      },
      getStates: function () {
        return $http.get('states.json', { cache: true }).then(function (response) {
          if (states) {
            return states;
          }
          states = { Muut: true };
          response.data.forEach(function (state) {
            states[state.name] = state.filter;
          });
          return states;
        });
      }
    };
  });
