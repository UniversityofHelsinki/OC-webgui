angular.module('ocWebGui.screen', ['ocWebGui.screen.service', 'ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('screen', {
        url: '/screen',
        templateUrl: 'screen/_screen.html',
        controller: 'ScreenController',
        controllerAs: 'screen'
      });
  })
  .controller('ScreenController', function ($interval, $scope, shared, Agents) {
    var vm = this;
    var fetchDataInterval;

    vm.teams = shared.getTeams();
    vm.states = shared.getStates();
    vm.message = 'Tilat';
    vm.agents = [];
    vm.green = 0;
    vm.yellow = 0;
    vm.red = 0;

    function fetchData() {
      Agents.query(function (agents) {
        var green = 0;
        var yellow = 0;
        var red = 0;

        // Agent status coloring and number tally.
        vm.agents = agents.map(function (agent) {
          if (agent.status === 'Sisäänkirjaus') {
            agent.color = 'green';
            green++;
          } else if (agent.status === 'JÄLKIKIRJAUS') {
            agent.color = 'yellow';
            yellow++;
          } else {
            agent.color = 'red';
            red++;
          }
          return agent;
        });

        vm.green = green;
        vm.yellow = yellow;
        vm.red = red;
      });
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
