angular.module('ocWebGui.stats', ['ui.router'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        url: '/stats',
        templateUrl: 'stats/_stats.html',
        controller: 'StatsController',
        controllerAs: 'stats'
      });
  })
  .controller('StatsController', function () {
    var vm = this;
    vm.title = 'Statistics';
  });
