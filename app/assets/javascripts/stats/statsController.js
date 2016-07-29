angular.module('ocWebGui.stats', ['ui.router', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        url: '/stats',
        templateUrl: 'stats/_stats.html',
        controller: 'StatsController',
        controllerAs: 'stats'
      });
  })
  .controller('StatsController', function ($scope, $http, $interval) {
    var vm = this;
    vm.title = 'Tilastot';
  });
