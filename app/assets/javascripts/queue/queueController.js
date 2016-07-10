angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'ocWebGui.shared.fullscreen', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        templateUrl: 'queue/_queue.html',
        controller: 'QueueController',
        controllerAs: 'queue'
      });
  })
  .controller('QueueController', function ($interval, $scope, Queue, MyFullscreen, $http) {
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
        xAxis: {
          tickFormat: function (d) {
            return d3.format(',f')(d);
          },
          axisLabel: 'Kellonaika',
          showMaxMin: true
        }
      }
    };
    vm.data = [{
      'key': 'foo',
      'bar': true,
      'color': 'skyblue',
      'values': []
    }, {
      'key': 'bar',
      'color': 'steelblue',
      'values': []
    }];

    function fetchStats() {
      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;
        var values = data.calls_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.calls !== 0; });
        vm.stats = data;
        vm.data[0].values = values;
      });
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

    vm.goFullscreen = function () {
      MyFullscreen.goFullScreen();
    }

    var fetchDataInterval = $interval(fetchData, 5 * 1000);
    var fetchStatsInterval = $interval(fetchStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
      $interval.cancel(fetchStatsInterval);
    });

    fetchData();
    fetchStats();

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
