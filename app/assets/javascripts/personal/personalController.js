angular.module('ocWebGui.personal', ['ui.router', 'ocWebGui.screen.service'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('personal', {
        url: '/personal',
        templateUrl: 'personal/_personal.html',
        controller: 'PersonalController',
        controllerAs: 'personal'
      });
  })
  .controller('PersonalController', function (Agents, $interval, $scope) {
      console.log("moi");

      var vm = this;

    function fetchData() {
      Agents.query(function (agents) {
          vm.agents = agents;
      });
    }

    var fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();
  });
