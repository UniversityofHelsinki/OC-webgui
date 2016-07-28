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
      });
      Queue.query(function (queue) {
        vm.queue = queue;
      });
      // Personal.getPersonalData().then(function (data) {
      //     console.log(data);
      //   vm.personalData = data;
      //   vm.personalData.myStatus = agents.filter(function () {
      //       return agent_id == data.agent_id;
      //   })[0].status;
      //     console.log(vm.personalData);
      // });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
