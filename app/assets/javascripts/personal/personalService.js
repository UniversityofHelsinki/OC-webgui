angular.module('ocWebGui.personal.service', ['ngResource', 'ocWebGui.login'])
  .factory('Personal', function ($resource) {
    return $resource('api/personal');
  });
