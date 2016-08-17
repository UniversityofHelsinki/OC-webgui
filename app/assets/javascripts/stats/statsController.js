angular.module('ocWebGui.stats', ['ui.router', 'ocWebGui.stats.today', 'ocWebGui.stats.status2'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        abstract: true,
        url: '/stats',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'stats/_stats.html'
          }
        }
      });
  });
