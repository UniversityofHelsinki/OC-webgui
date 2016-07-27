angular.module('ocWebGui.personal', ['ui.router', 'ocWebGui.screen.service', 'ocWebGui.queue.service', 'ocWebGui.personal.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('personal', {
        url: '/personal',
        templateUrl: 'personal/_personal.html',
        controller: 'PersonalController',
        controllerAs: 'personal'
      });
  })
  .controller('PersonalController', function (Agents, Queue, Personal, $interval, $scope) {
    var vm = this;

    function fetchData() {
      Agents.query(function (agents) {
        vm.agents = agents;
      });
      Queue.query(function (queue) {
        vm.queue = queue;
      });
      Personal.getPersonalData(function (data) {
        vm.personalData = data;
      });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
