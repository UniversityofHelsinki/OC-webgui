angular.module('ocWebGui.login', ['ui.router'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('login', {
        url: '/login',
        templateUrl: 'login/_login.html',
        controller: 'LoginController',
        controllerAs: 'login'
      });
  })
  .factory('User', function ($http) {
    var isAuthenticated = false;
    return {
      login: function (username, password, onSuccess, onError) {
        $http.post('login', { username: username, password: password })
          .then(function (response) {
            isAuthenticated = true;
            onSuccess();
          }, function (response) {
            isAuthenticated = false;
            onError(response.data.error);
          });
      },
      isAuthenticated: function () {
        return isAuthenticated;
      }
    };
  })
  .controller('LoginController', function (User, $rootScope, $state) {
    var vm = this;
    vm.title = 'Login';
    vm.login = function () {
      User.login(vm.username, vm.password, function () {
        $state.go($rootScope.returnToState, $rootScope.returnToParams);
      }, function (errorMessage) {
        vm.error = errorMessage;
      });
    };
  });
