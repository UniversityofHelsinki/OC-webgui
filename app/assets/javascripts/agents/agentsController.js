angular.module('ocWebGui.agents', ['ocWebGui.agents.service', 'ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('agents', {
        url: '/agents',
        templateUrl: 'agents/_agents.html',
        controller: 'AgentsController',
        controllerAs: 'agents'
      });
  })
  .controller('AgentsController', function ($interval, $scope, shared, Agents) {
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
          if (agent.status === 'Vapaa') {
            agent.color = 'green';
            green++;
          } else if (agent.status === 'Jälkikirjaus') {
            agent.color = 'yellow';
            yellow++;
          } else {
            agent.color = 'red';
            red++;
          }
          agent.time_in_status = Math.round(new Date().getTime() / 1000) - Math.round(new Date(agent.created_at).getTime() / 1000)
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
