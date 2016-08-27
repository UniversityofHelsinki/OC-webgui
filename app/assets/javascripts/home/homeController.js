angular.module('ocWebGui.home', ['ui.router', 'ocWebGui.login'])
  .config(function ($stateProvider, $urlRouterProvider) {
    $stateProvider
      .state('home', {
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
    vm.isAdmin = false;
    User.isAdmin().then(function (isAdmin) {
      vm.isAdmin = isAdmin;
    });
    vm.logout = User.logout;
  });
