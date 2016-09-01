angular.module('ocWebGui.stats', ['ui.router', 'ocWebGui.stats.today', 'ocWebGui.stats.status',
    'ocWebGui.shared.user.middleware'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.stats', {
        abstract: true,
        url: '/stats',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'stats/_stats.html'
          }
        },
        resolve: {
          requireAdmin: function (preloadUser, UserMiddleware) {
            return UserMiddleware.requireAdmin();
          }
        }
      });
  });
