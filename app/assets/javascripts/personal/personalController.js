angular.module('ocWebGui.personal', ['ui.router', 'ocWebGui.screen.service', 'ocWebGui.queue.service', 'ocWebGui.personal.service', 'ocWebGui.login', 'ocWebGui.shared.trimName.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('personal', {
        url: '/personal',
        templateUrl: 'personal/_personal.html',
        controller: 'PersonalController',
        controllerAs: 'personal'
      });
  })
  .controller('PersonalController', function (TrimName, Agents, Queue, User, Personal, $interval, $scope) {
    var vm = this;

    vm.trimName = TrimName.trim

    function fetchData() {
      Agents.query(function (agents) {
        vm.agents = agents;
        var myAgent = agents.find(function(agent) {
          return User.getUserData().agent_id === agent.id;
        });

        if (myAgent === undefined) {
          vm.myColor = 'grey';
        } else {
          vm.myColor = myAgent.color;
          agents.splice(agents.indexOf(myAgent), 1);
        }
      });

      Queue.query(function (queue) {
        vm.queue = queue;
      });

      Personal.get(function(data) {
        vm.data = data;
      });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
