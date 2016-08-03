angular.module('ocWebGui.color', ['ui.router', 'ocWebGui.login'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('color', {
        url: '/color',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'color/_color.html',
            controller: 'ColorController',
            controllerAs: 'color'
          }
        }
      });
  })
  .controller('ColorController', function ($interval, Settings) {
    var vm = this;
    vm.title = 'Värit';

    function clearMessage() {
      vm.message = '';
    }

    vm.message = 'Ladataan...';
    Settings.getColors().then(function (colors) {
      vm.colors = colors;
      clearMessage();
    });
    vm.save = function () {
      Settings.setColors(vm.colors).then(function () {
        vm.message = 'Kivat valinnat! Ne on nyt tallennettu!';
        $interval(clearMessage, 5000, 1);
      });
    };
  });
