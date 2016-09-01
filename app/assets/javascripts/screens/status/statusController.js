angular.module('ocWebGui.screens.status', ['ocWebGui.screens.status.service', 'ui.router', 'ocWebGui.shared.time', 'ocWebGui.shared.trimName.service', 'ngAnimate'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.status', {
        url: '/status',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_screen.html'
          },
          content: {
            templateUrl: 'screens/status/_status.html',
            controller: 'StatusController',
            controllerAs: 'status'
          }
        },
        navbarOverlay: true
      });
  })
  .controller('StatusController', function ($interval, $scope, Agents, TrimName, Settings) {
    var vm = this;
    var fetchDataInterval;

    vm.message = 'Tilat';
    vm.agents = [];
    vm.counts = { free: 0, call: 0, busy: 0 };
    vm.number_of_columns = 0;
    function fetchData() {
      Settings.getOthers().then(function (othersSettings) {
        vm.animated = othersSettings.animated;
      });

      Agents.query().then(function (agents) {
        vm.agents = agents;

        vm.counts = agents.reduce(function (counts, agent) {
          counts[agent.color]++;
          return counts;
        }, { free: 0, call: 0, busy: 0 });

        vm.number_of_columns = (agents.length > 9) ? 'four-col' : 'three-col';
      });
    }

    vm.trimName = TrimName.trim;

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
