angular.module('ocWebGui.color', ['ui.router', 'ocWebGui.login'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('color', {
        url: '/color',
        templateUrl: 'color/_color.html',
        controller: 'ColorController',
        controllerAs: 'color'
      });
  })
  .controller('ColorController', function (Settings) {
    var vm = this;
    vm.title = 'Värit';
    vm.colors = Settings.getColors();
    vm.save = function () {
      Settings.setColors(vm.colors);
    };
  });
