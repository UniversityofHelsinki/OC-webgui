angular.module('ocWebGui.settings.filters', ['ui.router', 'ocWebGui.shared.filter'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.settings.filters', {
        url: '/filters',
        templateUrl: 'settings/filters/_filters.html',
        controller: 'FiltersController',
        controllerAs: 'filters'
      });
  })
  .controller('FiltersController', function ($scope, $interval, Filter) {
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
      $scope.$watch('filters.teams', showNotification, true);
    });
    Filter.getStates().then(function (states) {
      vm.states = states;
      $scope.$watch('filters.states', showNotification, true);
    });
  });
