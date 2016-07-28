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
        height: 360,
        margin: {
          top: 30,
          right: 40,
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
          tickValues: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        },
        y2Axis: {
          tickValues: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
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
        var calls_values = data.calls_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });

        var queue_values = data.average_queue_duration_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });

        if (!angular.isDefined(vm.stats)) {
          vm.stats = {};
        }
        angular.extend(vm.stats, vm.stats, data);
        vm.data[0].values = calls_values;
        vm.data[1].values = queue_values;

        var nearest_ten = get_nearest_ten(0);
        if (nearest_ten != 0) {
          vm.options.chart.bars.yDomain[1] = nearest_ten;
          setTicks("y1", nearest_ten);
        }

        var nearest_ten2 = get_nearest_ten(1);
        if (nearest_ten2 != 0) {
          vm.options.chart.lines.yDomain[1] = nearest_ten2;
          setTicks("y2", nearest_ten2);
        }
      });
    }

    function fetchQueueStats() {
      $http.get('queue/stats.json').then(function (response) {
        var data = response.data;
        if (!angular.isDefined(vm.stats)) {
          vm.stats = {};
        }
        angular.extend(vm.stats, vm.stats, data);
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
        return Array.from({length: 10}, function (v, k) { return k; });
      }
      return Array.from({length: nearest_ten / 10}, function (v, k) { return k * 10; });
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
