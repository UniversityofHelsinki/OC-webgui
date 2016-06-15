angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        templateUrl: 'queue/_queue.html',
        controller: 'QueueController',
        controllerAs: 'queue'
      });
  })
  .controller('QueueController', function ($interval, $scope, Queue) {
    var vm = this;
    var fetchDataInterval;

    vm.message = 'Jono';

    vm.queue = [];

    vm.date = new Date();

    function fetchData() {
      Queue.query(function (queue) {
        vm.queue = queue;
      });
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();

    // mock data for testing css
    // vm.queue = [
    //   { line: 135, time_in_queue: 360 },
    //   { line: 137, time_in_queue: 123 },
    //   { line: 125, time_in_queue: 123 },
    //   { line: 137, time_in_queue: 123 },
    //   { line: 133, time_in_queue: 123 },
    //   { line: 137, time_in_queue: 123 },
    //   { line: 121, time_in_queue: 123 }
    // ];
  });
