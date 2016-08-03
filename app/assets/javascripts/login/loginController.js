angular.module('ocWebGui.login', ['ui.router'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('login', {
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
  .factory('User', function ($http, Settings) {
    var isAuthenticated = false;
    var userData = { username: null };
    return {
      login: function (username, password, onSuccess, onError) {
        $http.post('login', { username: username, password: password })
          .then(function (response) {
            isAuthenticated = true;
            userData = response.data;
            Settings.invalidateCache();
            onSuccess();
          }, function (response) {
            isAuthenticated = false;
            onError(response.data.error);
          });
      },
      isAuthenticated: function () {
        return isAuthenticated;
      },
      getUsername: function () {
        return userData.username;
      },
      getUserData: function () {
        return userData;
      },
      logout: function () {
        $http.delete('logout')
          .then(function () {
            isAuthenticated = false;
            userData = { username: null };
            Settings.invalidateCache();
          });
      }
    };
  })
  .controller('LoginController', function (User, $rootScope, $state) {
    var vm = this;
    vm.title = 'Kirjaudu sisään';
    vm.login = function () {
      User.login(vm.username, vm.password, function () {
        $state.go($rootScope.returnToState, $rootScope.returnToParams);
      }, function (errorMessage) {
        vm.error = errorMessage;
      });
    };
  });
