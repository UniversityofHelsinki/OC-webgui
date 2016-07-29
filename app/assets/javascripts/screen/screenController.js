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
    vm.green = 0;
    vm.yellow = 0;
    vm.red = 0;
    vm.number_of_columns = 0;

    function fetchData() {
      Agents.query(function (agents) {
        // Mock data
        // agents = [
        //    { agent_id: 1, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
        //    { agent_id: 2, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
        //    { agent_id: 3, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Puhelu', created_at: '2016-06-29T12:50:25.671Z' },
        //    { agent_id: 4, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Jälkikirjaus', created_at: '2016-06-29T12:50:25.671Z' },
        //    { agent_id: 5, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
        //    { agent_id: 6, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
        //  ];

        var green = 0;
        var yellow = 0;
        var red = 0;

        // Agent status number tally.
        agents.forEach(function (agent) {
          switch (agent.status) {
            case 'Vapaa':
              green++;
              break;
            case 'Jälkikirjaus':
            case 'Puhelu':
              yellow++;
              break;
            case String(agent.status.match(/^Varattu \(.*\)/)):
              agent.status = agent.status.match(/^Varattu \((.*)\)/)[1];
              // fallthrough
            default:
              red++;
              break;
          }
        });

        vm.agents = agents;
        vm.green = green;
        vm.yellow = yellow;
        vm.red = red;

        vm.number_of_columns = (agents.length > 9) ? 'four-col' : 'three-col';
      });
    }

    vm.trimName = TrimName.trim

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
