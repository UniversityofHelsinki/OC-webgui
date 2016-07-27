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
          tickValues: [0, 2, 4, 6, 8, 10],
        },
        y2Axis: {
          tickValues: [0, 2, 4, 6, 8, 10],
          tickFormat: function (currentSeconds) {
            var seconds = currentSeconds % 60;
            var minutes = Math.floor(currentSeconds / 60);
            function pad2(value) { return (value < 10 ? '0' : '') + value; }
            return pad2(minutes) + ':' + pad2(seconds);
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
        var values = data.calls_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          // .filter(function (item) { return item.calls !== 0; });
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; })
          ;
        if (!angular.isDefined(vm.stats)) {
          vm.stats = {};
        }
        angular.extend(vm.stats, vm.stats, data);
        vm.data[0].values = values;
        
        var nearest_ten = get_nearest_ten(0);
        if (nearest_ten == 0) return;

        vm.options.chart.bars.yDomain[1] = nearest_ten;
        setTicks("y1", nearest_ten);
      });
    }

    function fetchQueueStats() {
      $http.get('queue/stats.json').then(function (response) {
        var data = response.data;
        var values = data.average_waiting_time_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });
        if (!angular.isDefined(vm.stats)) {
          vm.stats = {};
        }
        angular.extend(vm.stats, vm.stats, data);
        vm.data[1].values = values;

        var nearest_ten = get_nearest_ten(1);
        if (nearest_ten == 0) return;

        vm.options.chart.lines.yDomain[1] = nearest_ten;
        
        setTicks("y2", nearest_ten);
      });
    }

    function setTicks(axis, nearest_ten) {
      if (axis == "y1") {
        var ticks = vm.options.chart.y1Axis.tickValues;
      } else if (axis == "y2") {
        var ticks = vm.options.chart.y2Axis.tickValues;
      }

      newTicks = get_new_ticks(nearest_ten);
      if (angular.equals(ticks, newTicks)) return;
      
      if (axis == "y1") {
        vm.options.chart.y1Axis.tickValues = newTicks.slice(0);
      } else if(axis == "y2") {
        vm.options.chart.y2Axis.tickValues = newTicks.slice(0);
      }

      vm.api.refresh();
    }

    function get_nearest_ten(i) {
      var max_val = d3.max(vm.data[i].values, function (x) { return x.calls; });
      if (max_val == null) {
        return 0;
      }
      return Math.ceil(max_val / 10) * 10;
    }

    function get_new_ticks(nearest_ten) {
      if (nearest_ten == 10) {
        return Array.from({length: 5}, function (v, k) { return k * 2; });
      }
      return Array.from({length: 5}, function (v, k) { return k * (nearest_ten / 5); });
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
    var fetchQueueStatsInterval = $interval(fetchQueueStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchContactStatsInterval);
      $interval.cancel(fetchQueueStatsInterval);
    });

    fetchData();
    fetchContactStats();
    fetchQueueStats();

  });
