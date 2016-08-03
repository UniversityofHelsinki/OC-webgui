angular.module('ocWebGui.stats', ['ui.router', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        url: '/stats',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'stats/_stats.html',
            controller: 'StatsController',
            controllerAs: 'stats'
          }
        }
      });
  })
  .controller('StatsController', function ($scope, $http) {
    var vm = this;
    vm.title = 'Tilastot';
  });
