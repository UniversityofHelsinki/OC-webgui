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
    $scope.trimName = trimName;

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
              // You may list multiple different statuses to trigger the same case like below
              case 'Jälkikirjaus', 'Puhelu':
                    agent.color = 'yellow';
                    yellow++;
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
      });
    }
      
    function trimName(wholename) {
        // var name = string(agent.name);
        
        var name = wholename;
        
        var parts = name.split(" ");
        name = parts.pop();
        name += " " + parts[0].charAt(0);
        
        return name;
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
