angular.module('ocWebGui.filterpanel', ['ui.router', 'ocWebGui.shared.filter'])
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
  .controller('FilterpanelController', function (Filter) {
    var vm = this;

    vm.teams = Filter.getTeams();
    vm.states = Filter.getStates();
  });
