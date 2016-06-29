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
        type: 'linePlusBarChart',
        height: 400,
        margin: {
          top: 30,
          right: 40,
          bottom: 60,
          left: 40
        },
        // TODO tosi pöljätapa.........
        x: function (d, i) { return i + 8; },
        y: function (d, i) { return d[1]; },
        bars: {
          forceY: [0,111]
        },
        lines: {
          forceY: [0,77]
        },
        xAxis: {
          tickFormat: function(d) {
            return d3.format(',f')(d);
          },

          axisLabel: "Kellonaika",
          showMaxMin: true,
          ticks: 10,
          //tickValues: [5, 7, 10, 15, 20,24 ]
        },
      }
    };
    // huonojuttu: menee epä synkkaan jos on eri määrä arvoja pylväällä ja 
    // viiva/pistediagrammilla
    vm.data = [{
      'key': 'foo',
      'bar': true,
      'color': 'skyblue',
      'values': [
        [8, 22],
        [9, 11],
        [10, null],
        [11, 26],
        [12, 15],
        [13, 65],
        [14, 34],
        [15, 25],
        [16,  5],
        [17, 14]
      ]
    }, {
      'key': 'bar',
      'color': 'steelblue',
      'values': [
        [8, 31],
        [9, 22],
        [10, 44],
        [11, 22],
        [12, 64],
        [13, null],
        [14, 13],
        [15, 4],
        [16, 75],
        [17, 3]
      ]
    }];

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
