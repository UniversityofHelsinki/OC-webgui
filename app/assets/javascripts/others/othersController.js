angular.module('ocWebGui.others', ['ui.router', 'ocWebGui.login'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('others', {
        url: '/others',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'others/_others.html',
            controller: 'OthersController',
            controllerAs: 'others'
          }
        }
      });
  })
  .controller('OthersController', function ($interval, Settings) {
    var vm = this;
    vm.title = 'Muut asetukset';

    function clearMessage() {
      vm.message = '';
    }

    vm.message = 'Ladataan...';
    Settings.getOthers().then(function (others) {
      vm.others = others;
    });
    vm.save = function () {
      Settings.setOthers(vm.others).then(function () {
        vm.message = 'Kivat valinnat! Ne on nyt tallennettu!';
        $interval(clearMessage, 5000, 1);
      });
    };
  });
