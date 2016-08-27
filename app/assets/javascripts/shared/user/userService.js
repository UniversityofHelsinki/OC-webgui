angular.module('ocWebGui.shared.user', [])
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
            return $q.reject(false);
          }
          return true;
        }, function () {
          return $q.reject(false);
        });
      },
      logout: function () {
        return $http.delete('logout')
          .then(function () {
            isAuthenticated = false;
            userData = { username: null };
            Settings.invalidateCache();
          });
      }
    };
  })
