angular.module('ocWebGui.colormanagement', ['ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('colormanagement', {
        url: '/colors',
        templateUrl: 'color_management/_colormanagement.html',
        controller: 'colorManagementController',
        controllerAs: 'colormanagement',
        navbarOverlay: true
      });
  })
  .controller('colorManagementController', function ($interval, $scope, shared, Agents, TrimName) {
    var vm = this;
    var fetchDataInterval;

    //vm.teams = shared.getTeams();
    //vm.states = shared.getStates();
    vm.message = 'Tilat';
    vm.agents = [];
    vm.green = 0;
    vm.yellow = 0;
    vm.red = 0;
    vm.number_of_columns = 0;

    function fetchData() {
        // Mock data
         agents = [
            { agent_id: 1, name: 'Meikäläinen Matti', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
            { agent_id: 2, name: 'Haukio Anni', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
            { agent_id: 3, name: 'Mustio Juha', team: 'Helpdesk', status: 'Puhelu', created_at: '2016-06-29T12:50:25.671Z' },
            { agent_id: 4, name: 'Korhonen Kauko', team: 'Helpdesk', status: 'Jälkikirjaus', created_at: '2016-06-29T12:50:25.671Z' },
            { agent_id: 5, name: 'Vaaksa Cecilia', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
            { agent_id: 6, name: 'Huokala Risto', team: 'Helpdesk', status: 'Vapaa', created_at: '2016-06-29T12:50:25.671Z' },
          ];

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
            default:
              red++;
              break;
          }
        });

        vm.agents = agents;
        vm.green = green;
        vm.yellow = yellow;
        vm.red = red;
    }

    vm.trimName = TrimName.trim;

 /*   fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    }); */

    fetchData();
  });