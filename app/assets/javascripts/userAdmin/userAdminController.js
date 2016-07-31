angular.module('ocWebGui.userAdmin', ['ui.router', 'ocWebGui.userAdmin.service', 'ocWebGui.shared.confirmClick'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('userAdmin', {
        url: '/userAdmin',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'userAdmin/_userAdmin.html',
            controller: 'UserAdminController',
            controllerAs: 'userAdmin'
          }
        }
      });
  })
  .controller('UserAdminController', function UserAdminController($scope, $timeout, AgentObjects, Users, UserAdmin) {
    var vm = this;
    vm.notification = '';

    // Setting agent reference for users requires fetching Agents to be complete first

    vm.agents = AgentObjects.query(function (agents) {
      vm.users = Users.query(function (users) {
        vm.users = users.map(function (user) {
          user.agent = agents.find(function (agent) {
            return agent.id === user.agent_id;
          });
          return user;
        });
      });
    });

    var setNotification = function (message) {
      vm.notification = message;
      $timeout(function () {
        vm.notification = '';
        vm.notifyClass = '';
      }, 5000);
    };

    var errorNotify = function (message) {
      vm.notifyClass = 'danger';
      setNotification(message);
    };

    var successNotify = function (user, message) {
      vm.notifyClass = 'success';
      setNotification(message);
    };

    var createUserSuccess = function (user, message) {
      vm.users.push(user);
      vm.newUserPassword = '';
      vm.newUserPasswordConfirmation = '';
      vm.newUserUsername = '';
      successNotify(user, message);
    };

    var deleteUserSuccess = function (user, message) {
      var userIndex = vm.users.map(function (u) { return u.id; }).indexOf(user.id);
      vm.users.splice(userIndex, 1);
      successNotify(user, message);
    };

    vm.createUser = function () {
      if (vm.newUserPassword !== vm.newUserPasswordConfirmation) {
        errorNotify('Salasanat eivät täsmää.');
        return;
      }
      UserAdmin.createUser(vm.newUserUsername, vm.newUserPassword, createUserSuccess, errorNotify);
    };

    vm.updateUser = function (user) {
      UserAdmin.updateUser(user, successNotify, errorNotify);
    };

    vm.deleteUser = function (user) {
      UserAdmin.deleteUser(user, deleteUserSuccess, errorNotify);
    };
  });

