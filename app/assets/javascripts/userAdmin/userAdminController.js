angular.module('ocWebGui.userAdmin', ['ui.router', 'ocWebGui.userAdmin.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('userAdmin', {
        url: '/userAdmin',
        templateUrl: 'userAdmin/_userAdmin.html',
        controller: 'UserAdminController',
        controllerAs: 'userAdmin'
      });
  })
  .controller('UserAdminController', function UserAdminController($scope, AgentObjects, Users) {
    var vm = this;

    vm.agents = AgentObjects;
    vm.users = Users;

    vm.createUser = function () {

    };
  });

