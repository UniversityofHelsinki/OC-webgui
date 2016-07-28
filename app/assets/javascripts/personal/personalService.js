angular.module('ocWebGui.personal.service', ['ngResource', 'ocWebGui.filterpanel', 'ocWebGui.login'])
  .factory('Personal', function ($resource, $http, User) {
    var userData = User.getUserData();
    return {
      getPersonalData: function () {
        return $http.post('personal.json', { agent_id: userData.agent_id });
      }
    };
  });
