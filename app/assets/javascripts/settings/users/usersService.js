angular.module('ocWebGui.settings.users.service', ['ngResource'])
  .factory('AgentObjects', function ($resource) {
    return $resource('api/agents');
  })
  .factory('Users', function ($resource) {
    return $resource('api/users/:userId', { userId: '@id' }, {
      update: { method: 'PUT' }
    });
  });
