angular.module('ocWebGui.home', ['ui.router', 'ocWebGui.shared.user'])
  .config(function ($stateProvider, $urlRouterProvider) {
    $stateProvider
      .state('app.home', {
        url: '/home',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'home/_home.html',
            controller: 'HomeController',
            controllerAs: 'home'
          }
        }
      });
    $urlRouterProvider.otherwise('home');
  })
  .controller('HomeController', function (User) {
    var vm = this;
    vm.isAuthenticated = User.isAuthenticated;
    vm.isAdmin = User.isAdmin;
    vm.logout = User.logout;
  });
