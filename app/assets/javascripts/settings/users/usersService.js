angular.module('ocWebGui.settings.users.service', ['ngResource'])
  .factory('AgentObjects', function ($resource) {
    return $resource('api/agents');
  })
  .factory('Users', function ($resource) {
    return $resource('api/users');
  })
  .factory('UserAdmin', function ($http) {
    return {
      createUser: function (username, password, onSuccess, onError) {
        $http.post('api/users', { user: { username: username,
                                      password: password }
                            })
          .then(function (response) {
            onSuccess(response.data);
          }, function (response) {
            onError(response.data);
          });
      },
      updateUser: function (user, onSuccess, onError) {
        $http.post('api/users/update', { user: { username: user.username,
                                             agent_id: user.agent_id,
                                             id: user.id,
                                             is_admin: user.is_admin }
                                    })
          .then(function (response) {
            onSuccess(response.data);
          }, function (response) {
            onError(response.data);
          });
      },
      deleteUser: function (user, onSuccess, onError) {
        $http.post('api/users/delete', { user: { id: user.id } })
          .then(function (response) {
            onSuccess(response.data);
          }, function (response) {
            onError(response.data);
          });
      }
    };
  });
