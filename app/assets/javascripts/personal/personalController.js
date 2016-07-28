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

        var myAgent = agents.filter(function (agent) {
            return User.getUserData().agent_id == agent.id;
        });

        if (myAgent[0] == undefined) {
            vm.myStatus = "Please login to webgui and OC";
            vm.myColor = "red";
        } else {
            vm.myStatus = myAgent[0].status;
            vm.myColor = myAgent[0].color;
        }
      });

      Queue.query(function (queue) {
        vm.queue = queue;
      });

      Personal.getPersonalData().then(function (response) {
          var data = response.data;
          vm.myCalls_count = data.answered_calls;
          vm.myCalls_avg = data.average_call_duration;
          vm.myAftercalls_avg = data.average_after_call_duration;
      })
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
