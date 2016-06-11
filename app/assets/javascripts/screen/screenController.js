angular.module('ocWebGui.screen', ['ui.router', 'ngResource',
    'ocWebGui.shared.time', 'ocWebGui.filterpanel'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('screen', {
        url: '/screen',
        templateUrl: 'screen/_screen.html',
        controller: 'ScreenController',
        controllerAs: 'screen'
      });
  })
  .factory('Agents', function ($resource, shared) {
    var teams = shared.getTeams();
    var states = shared.getStates();
    return $resource('agents.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (agents) {
          return agents.filter(function (agent) {
            return states[agent.status] && teams[agent.team];
          });
        }
      }
    });
  })
  .controller('ScreenController', function ($interval, $scope, Agents) {
    var fetchDataInterval;
    var vm = this;

    vm.message = 'Tilat';
    vm.agents = [];

    function fetchData() {
      Agents.query(function (agents) {
        vm.agents = agents;
      });
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
