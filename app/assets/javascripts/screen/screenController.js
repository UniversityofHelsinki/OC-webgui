angular.module('ocWebGui.screen', ['ocWebGui.screen.service', 'ui.router', 'ocWebGui.shared.time', 'ocWebGui.shared.trimName.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('screen', {
        url: '/screen',
        templateUrl: 'screen/_screen.html',
        controller: 'ScreenController',
        controllerAs: 'screen',
        navbarOverlay: true
      });
  })
  .controller('ScreenController', function ($interval, $scope, shared, Agents, TrimName) {
    var vm = this;
    var fetchDataInterval;

    vm.teams = shared.getTeams();
    vm.states = shared.getStates();
    vm.message = 'Tilat';
    vm.agents = [];
    vm.counts = { free: 0, call: 0, busy: 0 };
    vm.number_of_columns = 0;

    function fetchData() {
      Agents.query(function (agents) {
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
