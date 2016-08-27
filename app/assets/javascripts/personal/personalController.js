angular.module('ocWebGui.personal', ['ui.router', 'ocWebGui.screens.status.service',
    'ocWebGui.screens.queue.service', 'ocWebGui.personal.service', 'ocWebGui.shared.user',
    'ocWebGui.shared.trimName.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app.personal', {
        url: '/personal',
        views: {
          content: {
            templateUrl: 'personal/_personal.html',
            controller: 'PersonalController',
            controllerAs: 'personal'
          }
        },
        navbarOverlay: true
      });
  })
  .controller('PersonalController', function ($q, TrimName, Agents, Queue, User, Personal, $interval, $scope) {
    var vm = this;

    vm.trimName = TrimName.trim;

    function fetchData() {
      Agents.query(function (agents) {
        vm.agents = agents;
        vm.currentAgent = vm.agents.find(function (agent) {
          return User.getAgentId() === agent.id;
        });
        if (vm.currentAgent) {
          vm.agents = vm.agents.filter(function (agent) {
            return agent !== vm.currentAgent;
          });
        }
      });

      Queue.query().then(function (queue) {
        vm.queue = queue;
      });

      Personal.get(function (data) {
        vm.data = data;
      });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
