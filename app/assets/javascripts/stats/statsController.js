angular.module('ocWebGui.stats', ['ui.router', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        url: '/stats',
        templateUrl: 'stats/_stats.html',
        controller: 'StatsController',
        controllerAs: 'stats'
      });
  })
  .controller('StatsController', function ($scope, $http, $interval) {
    var vm = this;
    vm.title = 'Tilastot';

    vm.options = {
      chart: {
        type: 'lineChart',
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
        },
        forceY: [0, 10],
      }
    };
    vm.data = [{
      'key': 'Jonottajia',
      'color': '#000',
      'values': []
    }];

    function fetchQueueStats() {
      $http.get('queue/stats.json').then(function (response) {
        var data = response.data;
        var values = data.queues_by_hour
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
  //        .filter(function (item) { return item.calls !== 0; });
        if (!angular.isDefined(vm.stats)) {
          vm.stats = {};
        }
        angular.extend(vm.stats, vm.stats, data);
        vm.data[0].values = values;
      });
    }

    var fetchQueueStatsInterval = $interval(fetchQueueStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchQueueStatsInterval);
    });

    fetchQueueStats();
  });
