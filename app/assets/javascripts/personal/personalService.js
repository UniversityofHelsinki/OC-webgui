angular.module('ocWebGui.personal.service', ['ngResource', 'ocWebGui.filterpanel', 'ocWebGui.login'])
  .factory('Personal', function ($resource, $http, User) {
    var userData = User.getUserData();
    return {
      getPersonalData: function () {
        $http.post('personal.json', { agent_id: userData.agent_id })
          .then(function (response) {
            return response;
          });
      }
    };
  });


/*
      });
  })
  .factory('User', function ($http) {
    var isAuthenticated = false;
    var userData = { username: null };
    return {
      login: function (username, password, onSuccess, onError) {
        $http.post('login', { username: username, password: password })
          .then(function (response) {
            isAuthenticated = true;
            userData = response.data;
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
      logout: function () {
        $http.delete('logout')
          .then(function () {
            isAuthenticated = false;
            userData = { username: null };
          });
      }
    };
*/
