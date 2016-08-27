angular.module('ocWebGui.settings.users', ['ui.router', 'ocWebGui.settings.users.service', 'ocWebGui.shared.confirmClick'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.settings.users', {
        url: '/users',
        templateUrl: 'settings/users/_users.html',
        controller: 'UsersController',
        controllerAs: 'users',
        resolve: {
          requireAdmin: function (UserMiddleware) {
            return UserMiddleware.requireAdmin();
          }
        }
      });
  })
  .controller('UsersController', function ($scope, $interval, AgentObjects, Users, UserAdmin) {
    var vm = this;

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

    var notificationTimeout;

    var setNotification = function (message) {
      vm.notification = message;
      // If a previous notification was already visible, reset the timer to hide the notification
      $interval.cancel(notificationTimeout);

      notificationTimeout = $interval(function () {
        vm.notification = '';
        vm.notifyClass = '';
      }, 5000, 1);
    };

    var errorNotify = function (message) {
      vm.notifyClass = 'danger';
      setNotification(message);
    };

    var successNotify = function (message) {
      vm.notifyClass = 'success';
      setNotification(message);
    };

    var createUserSuccess = function (user) {
      vm.users.push(user);
      vm.newUserPassword = '';
      vm.newUserPasswordConfirmation = '';
      vm.newUserUsername = '';
      successNotify('Käyttäjä ' + user.username + ' lisätty tietokantaan!');
    };

    var updateUserSuccess = function (user) {
      successNotify('Käyttäjän ' + user.username + ' tiedot päivitetty!');
    };

    var deleteUserSuccess = function (user) {
      var userIndex = vm.users.map(function (u) { return u.id; }).indexOf(user.id);
      vm.users.splice(userIndex, 1);
      successNotify('Käyttäjä ' + user.username + ' poistettu onnistuneesti!');
    };

    vm.createUser = function () {
      if (vm.newUserPassword !== vm.newUserPasswordConfirmation) {
        errorNotify('Salasanat eivät täsmää.');
        return;
      }
      UserAdmin.createUser(vm.newUserUsername, vm.newUserPassword, createUserSuccess, errorNotify);
    };

    vm.updateUser = function (user) {
      UserAdmin.updateUser(user, updateUserSuccess, errorNotify);
    };

    vm.deleteUser = function (user) {
      UserAdmin.deleteUser(user, deleteUserSuccess, errorNotify);
    };
  });

