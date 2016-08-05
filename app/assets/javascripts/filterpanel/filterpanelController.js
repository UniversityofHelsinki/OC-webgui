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
  .controller('FilterpanelController', function ($scope, $interval, Filter) {
    var vm = this;

    var notificationInterval;
    function clearMessage() {
      vm.notification = '';
    }
    function showNotification(newValue, oldValue) {
      if (oldValue === newValue) {
        return;
      }
      $interval.cancel(notificationInterval);
      vm.notification = 'Valintasi on tallennettu väliaikaisesti!';
      notificationInterval = $interval(clearMessage, 2000, 1);
    }

    Filter.getTeams().then(function (teams) {
      vm.teams = teams;
      $scope.$watch('filterpanel.teams', showNotification, true);
    });
    Filter.getStates().then(function (states) {
      vm.states = states;
      $scope.$watch('filterpanel.states', showNotification, true);
    });
  });
