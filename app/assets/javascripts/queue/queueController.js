angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_screen.html'
          },
          content: {
            templateUrl: 'queue/_queue.html',
            controller: 'QueueController',
            controllerAs: 'queue'
          }
        },
        navbarOverlay: true
      });
  })
  .controller('QueueController', function ($interval, $scope, Queue, $http, Settings) {
    var vm = this;
    vm.api = {};

    vm.options = {
      chart: {
        type: 'linePlusBarChart',
        height: 550,
        margin: {
          top: 30,
          right: 70,
          bottom: 60,
          left: 70
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
        },
        y2Axis: {
          tickFormat: function (seconds) {
            var formatTime = d3.time.format('%H:%M');
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

    function getMaxValPlusOne(i) {
      var maxVal = d3.max(vm.data[i].values, function (x) { return x.calls; });
      if (maxVal == null) {
        return 1;
      }
      return maxVal + 1;
    }

    function fetchContactStats() {
      Settings.getOthers().then(function (others) {
        vm.otherSettings = others;
      });

      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;

        var callsValues = data.calls_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= vm.otherSettings['working_day_start'] && item.hour <= vm.otherSettings['working_day_end']; });

        var queueValues = data.average_queue_duration_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= vm.otherSettings['working_day_start'] && item.hour <= vm.otherSettings['working_day_end']; });

        vm.stats = data;
        vm.data[0].values = callsValues;
        vm.data[1].values = queueValues;
        var callMax = getMaxValPlusOne(0);
        // Multiply by 1.05 so highest value is high enough that highest point in chart isn't hidden
        var queueMax = getMaxValPlusOne(1) * 1.05;
        vm.options.chart.bars.yDomain[1] = callMax;
        vm.options.chart.lines.yDomain[1] = queueMax;
        vm.options.chart.y1Axis.tickValues = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
        vm.options.chart.y2Axis.tickValues = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
        vm.api.refresh();
      });
    }

    vm.queue = [];
    vm.date = new Date();

    function fetchData() {
      Queue.query(function (queue) {
        vm.queue = queue;
      });
      // Also update date/time
      vm.date = new Date();
    }
    var fetchDataInterval = $interval(fetchData, 1000);
    var fetchContactStatsInterval = $interval(fetchContactStats, 30 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchData();
    fetchContactStats();
  });
