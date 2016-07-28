angular.module('ocWebGui.personal', ['ui.router', 'ocWebGui.screen.service', 'ocWebGui.queue.service', 'ocWebGui.personal.service', 'ocWebGui.login'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('personal', {
        url: '/personal',
        templateUrl: 'personal/_personal.html',
        controller: 'PersonalController',
        controllerAs: 'personal'
      });
  })
  .controller('PersonalController', function (Agents, Queue, User, Personal, $interval, $scope) {
    var vm = this;

    function fetchData() {
      Agents.query(function (agents) {
        vm.agents = agents;

        vm.myStatus = agents.filter(function (agent) {
          return User.getUserData().agent_id == agent.id;
        })[0].status;

        vm.myColor = agents.filter(function (agent) {
            return User.getUserData().agent_id == agent.id;
        })[0].color;
      });

      Queue.query(function (queue) {
        vm.queue = queue;
      });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
