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
          tickValues: [0, 2]
        },
        y2Axis: {
          tickValues: [0, 2]
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
        var values = data.queue_items_by_hour
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
      if (axis == "y1")
        var ticks = vm.options.chart.y1Axis.tickValues;

      if (axis == "y2")
        var ticks = vm.options.chart.y2xis.tickValues;
 
      newTicks = get_ticks(nearest_ten);

      if (angular.equals(ticks, newTicks)) return;
      
      while (ticks.length > 0) {
        ticks.pop();
      }

      newTicks.forEach(function (tick) {
        ticks.push(tick);
      });
    }

    function get_nearest_ten(i) {
      var max_val = d3.max(vm.data[i].values, function(x) { return x.calls; });
      if (max_val == null) {
        return 0;
      }
      return Math.ceil(max_val / 10) * 10;
    }

    function get_ticks(nearest_ten) {
      if (nearest_ten == 10) {
        return Array.from({length: 10}, (v, k) => k);
      }
      return Array.from({length: nearest_ten / 10}, (v, k) => k * 10);
    }


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
