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
  .controller('UserAdminController', function UserAdminController($scope, $timeout, AgentObjects, Users, UserAdmin) {
    var vm = this;

    vm.agents = AgentObjects;
    vm.users = Users;

    var testihomoke = function(parent, varname, message) {
      parent[varname] = message;
      $timeout(function() {
        parent[varname] = '';
      }, 5000)
    }
/*
    var successMessage = function () {
      vm.errorMessage = '';
      vm.successMessage = "Successfully created user!";
      $timeout(function() {
        vm.successMessage = '';
      }, 5000);
    };

    var errorMessage = function(error) {
      vm.successMessage = '';
      vm.errorMessage = error;
      $timeout(function() {
        vm.errorMessage = "";
      }, 5000);
    };*/

    var errorNotify = function(message) {
      vm.notifyClass = "danger"
      setNotification(message);
    }

    var successNotify = function() {
      vm.notifyClass = "success"
      setNotification('Käyttäjä luotu onnistuneesti!');
    }

    var setNotification = function (message) {
      vm.notification = message;
      $timeout(function () {
        vm.notification = "";
        vm.notifyClass = "";
      }, 5000);
    }

    vm.createUser = function () {
      if(vm.newUserPassword !== vm.newUserPasswordConfirmation) {
        errorNotify('Salasanat eivät täsmää.');
        return;
      }
      UserAdmin.createUser(vm.newUserUsername, vm.newUserPassword, successNotify, errorNotify);
    };
  });

