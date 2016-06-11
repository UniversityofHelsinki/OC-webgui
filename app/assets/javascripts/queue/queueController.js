angular.module('ocWebGui.queue', ['ui.router', 'ngResource', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        templateUrl: 'queue/_queue.html',
        controller: 'QueueController',
        controllerAs: 'queue'
      });
  })
  .factory('Queue', function ($resource) {
    function getLanguage(line) {
      switch (line) {
        case 135:
        case 137:
        case 136:
          return 'Fin';
        case 125:
        case 131:
        case 121:
          return 'Eng';
        case 133:
          return 'Swe';
        default:
          return 'Unknown';
      }
    }
    return $resource('queue.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (queue) {
          return queue.map(function (queuer) {
            queuer.language = getLanguage(queuer.line);
            return queuer;
          });
        }
      }
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
