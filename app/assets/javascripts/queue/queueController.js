angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'nvd3'])
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

    vm.options = {
        chart: {
            type: 'discreteBarChart',
            // height: 400,
            margin : {
                top: 20,
                right: 20,
                bottom: 40,
                left: 55
            },
            x: function(d) { return d.x; },
            y: function(d) { return d.y; },
            useInteractiveGuideline: true,
            duration: 0,    
            yDomain: [-1,1],
            yAxis: {
                tickFormat: function(d){
                   return d3.format('.01f')(d);
                }
            }
        }
    };
    
    vm.data = [{ values: [
      {x: 3, y: 0.3},
      {x: 2, y: 0.6},
      {x: 1, y: 0.8}
      
      ], key: 'Vastattujen puheluiden määrä' }];   

    var fetchDataInterval;

    vm.message = 'Jono';

    vm.queue = [];

    vm.date = new Date();

    function fetchData() {
      Queue.query(function (queue) {
        vm.queue = queue.filter(function (queuer) {
          return queuer.language !== 'Unknown';
        });
      });
      // Also update date/time
      vm.date = new Date();
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();

    // mock data for testing css
    // vm.queue = [
    //   { line: 135, language: 'Fin', time_in_queue: 360 },
    //   { line: 137, language: 'Fin', time_in_queue: 123 },
    //   { line: 125, language: 'Eng', time_in_queue: 123 },
    //   { line: 137, language: 'Fin', time_in_queue: 123 },
    //   { line: 133, language: 'Swe', time_in_queue: 53  },
    //   { line: 131, language: 'Eng', time_in_queue: 123 },
    //   { line: 121, language: 'Eng', time_in_queue: 214 }
    // ];
  });
