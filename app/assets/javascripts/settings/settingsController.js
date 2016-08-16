angular.module('ocWebGui.settings', ['ui.router', 'ocWebGui.settings.filters',
    'ocWebGui.settings.general', 'ocWebGui.settings.colors',
    'ocWebGui.settings.users'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('settings', {
        abstract: true,
        url: '/settings',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'settings/_settings.html'
          }
        }
      });
  });
