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
  .factory('User', function ($q, $http, Settings) {
    var isAuthenticated = false;
    var userData = { username: null };

    function fetchUserData() {
      if (isAuthenticated) {
        return $q.resolve(userData);
      }
      return $http.get('user.json').then(function (response) {
        isAuthenticated = true;
        userData = response.data;
        return userData;
      }, function () {
        isAuthenticated = false;
        userData = { username: null };
        return $q.reject();
      });
    }

    return {
      login: function (username, password) {
        return $http.post('login', { username: username, password: password })
          .then(function (response) {
            isAuthenticated = true;
            userData = response.data;
            Settings.invalidateCache();
            return userData;
          }, function (response) {
            isAuthenticated = false;
            return $q.reject(response.data.error);
          });
      },
      isAuthenticated: function () {
        return isAuthenticated;
      },
      getUsername: function () {
        return fetchUserData().then(function (userData) {
          return userData.username;
        });
      },
      getUserData: function () {
        return fetchUserData();
      },
      isAdmin: function () {
        return fetchUserData().then(function (userData) {
          if (!userData.is_admin) {
            return $q.reject();
          }
        });
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
    vm.login = function () {
      User.login(vm.username, vm.password).then(function () {
        $state.go($rootScope.returnToState, $rootScope.returnToParams);
      }, function (errorMessage) {
        vm.error = errorMessage;
      });
    };
  });
