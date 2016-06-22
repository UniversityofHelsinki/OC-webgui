angular.module('ocWebGui.filterpanel', ['ui.router', 'ngResource'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('filterpanel', {
        url: '/filterpanel',
        templateUrl: 'filterpanel/_filterpanel.html',
        controller: 'FilterpanelController',
        controllerAs: 'filterpanel'
      });
  })
  .controller('FilterpanelController', function FilterpanelController($scope, shared) {
    var vm = this;

    vm.teams = shared.getTeams();
    vm.states = shared.getStates();
  })
  .factory('shared', function () {
    var teams = {
      'Hakijapalvelut': false,
      'Helpdesk': true,
      'Opiskelijaneuvonta': false,
      'OrangeContact 1': false,
      'Puhelinvaihde': false,
      'Uaf': false
    };
    var states = {
      'BACKOFFICE': false,
      '<TELJENTÄ>': false,
      'Sisäänkirjaus': true,
      'TAUKO': true,
      '12648': false,
      'PUHELU (Sisään)': true,
      'PUHELU (Ulos)': true
    };

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
