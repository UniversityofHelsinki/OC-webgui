angular.module('ocWebGui.userAdmin.service', ['ngResource'])
  .factory('AgentObjects', function ($resource) {
    return $resource('agents.json').query(function (data) {
      return data;
    });
  })
  .factory('Users', function ($resource) {
    return $resource('users.json').query(function (data) {
      return data;
    });
  })
  .factory('UserAdmin', function ($resource, $http) {
    return {
      createUser: function (username, password, onSuccess, onError) {
        $http.post('users', { user: { username: username, password: password } })
          .then(function (response) {
            onSuccess();
           }, function (response) {
             onError(response.data);
           });
        }
      /*
      createUser: function (username, password) {
        var data = { user: { username: username, password: password }}
        $resource('users', {}, {
          create: {method: 'POST', params: data }
        }).create();*/

      }    
  });

/*
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
*/
/*


    var agents = [];
    $resource('agents.json').query(function (data) {
      agents = data;
    });

    var users = [];
    $resource('users.json').query(function (data) {
      users = data;
    });

    return {
      getAgents: function () {
        return $resource('agents.json');
      },
      getUsers: function () {
        return users;
      }
    };
*/
