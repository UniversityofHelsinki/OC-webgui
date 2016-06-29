angular.module('ocWebGui.status', ['ocWebGui.status.service', 'ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('status', {
        url: '/status',
        templateUrl: 'status/_status.html',
        controller: 'StatusController',
        controllerAs: 'status'
      });
  })
  .controller('StatusController', function ($interval, $scope, shared, Status) {
    var vm = this;
    var fetchDataInterval;

    vm.teams = shared.getTeams();
    vm.states = shared.getStates();
    vm.message = 'Tilat';
    vm.status = [];
    vm.green = 0;
    vm.yellow = 0;
    vm.red = 0;

    function fetchData() {
      Status.query(function (status) {
        var green = 0;
        var yellow = 0;
        var red = 0;

        // Agent status coloring and number tally.
        vm.status = agents.map(function (agent) {
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
