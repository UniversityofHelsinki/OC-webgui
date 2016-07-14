angular.module('ocWebGui.navbar', ['ui.router', 'ocWebGui.login', 'ocWebGui.shared.fullscreen', 'FBAngular'])
  .controller('NavbarController', function ($scope, $http, User, MyFullscreen, Fullscreen) {
    var vm = this;
    
    vm.isAuthenticated = User.isAuthenticated;
    vm.username = User.getUsername;
    vm.logout = User.logout;

    vm.isFullscreen = Fullscreen.isEnabled();
    vm.goFullscreen = function () {
      MyFullscreen.goFullScreen();
    };

    Fullscreen.$on('FBFullscreen.change', function(event, isEnabled){
      vm.isFullscreen = isEnabled;
    });

  });
