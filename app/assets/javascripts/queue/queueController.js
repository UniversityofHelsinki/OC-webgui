angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        templateUrl: 'queue/_queue.html',
        controller: 'QueueController',
        controllerAs: 'queue',
        navbarOverlay: true
      });
  })
  .controller('QueueController', function ($interval, $scope, Queue, $http) {
    var vm = this;
    vm.api = {};

    vm.options = {
      chart: {
        type: 'linePlusBarChart',
        height: 550,
        margin: {
          top: 30,
          right: 90,
          bottom: 60,
          left: 40
        },
        x: function (d) { return d.hour; },
        y: function (d) { return d.calls; },
        bars: {
          forceY: [0, 50],
          yDomain: [0, 10]
        },
        lines: {
          forceY: [0, 50],
          yDomain: [0, 10]
        },
        xAxis: {
          tickFormat: function (d) {
            return d3.format(',f')(d);
          },
          axisLabel: 'Kellonaika',
          showMaxMin: true
        },
        y1Axis: {
          ticks: 5
        },
        y2Axis: {
          ticks: 5,
          tickFormat: function (seconds) {
            var formatTime = d3.time.format("%H:%M");
            return formatTime(new Date(1864, 7, 7, 0, seconds));
          }
        },
        legend: {
          maxKeyLength: 100
        },
        duration: 500
      }
    };
    vm.data = [{
      'key': 'Puheluja tunnissa',
      'bar': true,
      'color': '#000000',
      'values': []
    }, {
      'key': 'Keskim. jonotusaika',
      'color': '#ff0000',
      'values': []
    }];


    function fetchContactStats() {
      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;
        var callsValues = data.calls_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });

        var queueValues = data.average_queue_duration_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });

        vm.stats = data;
        vm.data[0].values = callsValues;
        vm.data[1].values = queueValues;
        vm.options.chart.bars.yDomain[1] = getMaxValPlusOne(0);
        vm.options.chart.lines.yDomain[1] = getMaxValPlusOne(1);
      });
    }

    function getMaxValPlusOne(i) {
      var maxVal = d3.max(vm.data[i].values, function (x) { return x.calls; });
      if (maxVal == null) {
        return 1;
      }
      return maxVal + 1;
    }

    vm.message = 'Jono';

    vm.queue = [];

    vm.date = new Date();

    function fetchData() {
      Queue.query(function (queue) {
        vm.queue = queue;
      });
      // Also update date/time
      vm.date = new Date();
    }
    var fetchDataInterval = $interval(fetchData, 5 * 1000);
    var fetchContactStatsInterval = $interval(fetchContactStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchData();
    fetchContactStats();
  });
