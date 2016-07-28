angular.module('ocWebGui.screen', ['ocWebGui.screen.service', 'ui.router', 'ocWebGui.shared.time'])
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
    vm.number_of_columns = 0;

    function fetchData() {
      Agents.query(function (agents) {
        var green = 0;
        var yellow = 0;
        var red = 0;

        // Agent status coloring and number tally.
        vm.agents = agents.map(function (agent) {
          switch (agent.status) {
            case 'Vapaa':
              agent.color = 'green';
              green++;
              break;
            case 'Jälkikirjaus':
            case 'Puhelu':
              agent.color = 'yellow';
              yellow++;
              break;
            case String(agent.status.match(/^Varattu \(.*\)/)):
              agent.status = agent.status.match(/\((.*?)\)/ )[1];
              break;
            default:
              agent.color = 'red';
              red++;
              break;
          }
          return agent;
        });

        vm.green = green;
        vm.yellow = yellow;
        vm.red = red;

        vm.number_of_columns = (agents.length > 9) ? 'four-col' : 'three-col';
      });
    }

    vm.trimName = function (agent) {
      return agent.first_name + ' ' + agent.last_name.charAt(0);
    };

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
