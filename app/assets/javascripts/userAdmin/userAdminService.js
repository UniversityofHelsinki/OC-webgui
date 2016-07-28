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
  .factory('UserAdmin', function () {
    return {
      createUser: function (username, password, passwordConfirmation) {
        if (password !== passwordConfirmation) return false;
        return true;
      }
    };
  });

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
