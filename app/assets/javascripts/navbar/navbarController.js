angular.module('ocWebGui.navbar', ['ui.router', 'ocWebGui.login', 'FBAngular'])
  .controller('NavbarController', function ($scope, $http, User, Fullscreen, $interval) {
    var vm = this;
    
    vm.isAuthenticated = User.isAuthenticated;
    vm.username = User.getUsername;
    vm.logout = User.logout;

    $scope.isFullscreen = Fullscreen.isEnabled();

    vm.goFullscreen = function () {
      if (Fullscreen.isEnabled()) {
        Fullscreen.cancel();
      } else {
        Fullscreen.all();
      }
    };

    Fullscreen.$on('FBFullscreen.change', function(event, isEnabled){
      $scope.isFullscreen = isEnabled;
      $scope.$apply(); 
    });
  });
