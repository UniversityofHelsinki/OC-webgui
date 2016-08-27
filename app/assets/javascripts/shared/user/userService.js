angular.module('ocWebGui.shared.user', [])
  .factory('User', function ($q, $http, Settings) {
    var isAuthenticated = false;
    var userData = null;

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
            userData = null;
            return $q.reject(response.data.error);
          });
      },
      logout: function () {
        return $http.delete('logout')
          .then(function () {
            isAuthenticated = false;
            userData = null;
            Settings.invalidateCache();
          });
      },
      fetchUser: function () {
        if (isAuthenticated) {
          return $q.resolve(true);
        }
        return $http.get('user.json').then(function (response) {
          isAuthenticated = true;
          userData = response.data;
          return true;
        }, function () {
          isAuthenticated = false;
          userData = null;
          return false;
        });
      },
      isAuthenticated: function () {
        return isAuthenticated;
      },
      getUsername: function () {
        if (!isAuthenticated) {
          return null;
        }
        return userData.username;
      },
      getAgentId: function () {
        if (!isAuthenticated) {
          return null;
        }
        return userData.agent_id;
      },
      isAdmin: function () {
        return isAuthenticated && userData.is_admin;
      }
    };
  });
