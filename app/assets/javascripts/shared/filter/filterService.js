angular.module('ocWebGui.shared.filter', ['ngResource'])
  .factory('Filter', function ($http) {
    var teams = {};
    var states = { 'Muut': true };

    $http.get('teams.json').then(function (response) {
      response.data.forEach(function (team) {
        teams[team.name] = team.filter;
      });
    });

    $http.get('states.json').then(function (response) {
      response.data.forEach(function (state) {
        states[state.name] = state.filter;
      });
    });

    return {
      getTeams: function () {
        return teams;
      },
      setTeams: function (value) {
        teams = value;
      },
      getStates: function () {
        return states;
      },
      setStates: function (value) {
        states = value;
      }
    };
  });
