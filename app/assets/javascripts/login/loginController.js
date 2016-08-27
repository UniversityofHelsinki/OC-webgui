angular.module('ocWebGui.login', ['ui.router', 'ocWebGui.shared.user'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.login', {
        url: '/login',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'login/_login.html',
            controller: 'LoginController',
            controllerAs: 'login'
          }
        }
      });
  })
  .controller('LoginController', function (User, $rootScope, $state) {
    var vm = this;
    vm.login = function () {
      User.login(vm.username, vm.password).then(function () {
        $state.go($rootScope.returnToState, $rootScope.returnToParams);
      }, function (errorMessage) {
        vm.error = errorMessage;
      });
    };
  });
