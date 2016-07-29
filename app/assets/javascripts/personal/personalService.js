angular.module('ocWebGui.personal.service', ['ngResource', 'ocWebGui.filterpanel', 'ocWebGui.login'])
  .factory('Personal', function ($resource) {
    return $resource('personal.json');
  });
