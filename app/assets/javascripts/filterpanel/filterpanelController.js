angular.module('ocWebGui.filterpanel', ['ui.router', 'ngResource'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('filterpanel', {
        url: '/filterpanel',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'filterpanel/_filterpanel.html',
            controller: 'FilterpanelController',
            controllerAs: 'filterpanel'
          }
        }
      });
  })
  .controller('FilterpanelController', function FilterpanelController($scope, shared) {
    var vm = this;

    vm.teams = shared.getTeams();
    vm.states = shared.getStates();
  })
  .factory('shared', function ($resource) {
    var teams = {};
    var states = { 'Muut': true };

    $resource('teams.json').query(function (data) {
      data.forEach(function (team) {
        teams[team.name] = team.filter;
      });
    });

    $resource('states.json').query(function (data) {
      data.forEach(function (state) {
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
