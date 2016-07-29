angular.module('ocWebGui.personal.service', ['ngResource', 'ocWebGui.filterpanel', 'ocWebGui.login'])
  .factory('Personal', function ($resource, $http, User) {
    return $resource('personal.json');    
  });
