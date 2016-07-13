angular.module('ocWebGui.navbar', ['ui.router', 'ocWebGui.login', 'ocWebGui.shared.fullscreen'])
  .controller('NavbarController', function ($scope, $http, User, MyFullscreen) {
    var vm = this;
    
    vm.isFullscreen = false;
    vm.goFullscreen = function () {
      MyFullscreen.goFullScreen();
      vm.isFullscreen = !vm.isFullscreen;
    };

    vm.isAuthenticated = User.isAuthenticated;
    vm.username = User.getUsername;
    vm.logout = User.logout;
  });
