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
  .controller('StatsController', function ($interval, $scope, $http) {
    var vm = this;
    vm.title = 'Tilastot';

    vm.api = {};
    vm.options = {
      chart: {
        type: 'scatterChart',
        width: 700,
        height: 550,
        margin: {
          top: 30,
          right: 90,
          bottom: 60,
          left: 90
        },
        color: d3.scale.category10().range(),
        showDistX: true,
        showDistY: true,
        xAxis: {
          axisLabel: 'Kellonaika',
          tickFormat: function (d) {
            return d3.time.format('%H.%M')(new Date(d));
          }
        },
        yAxis: {
          axisLabel: 'Jonotusaika',
          axisLabelDistance: 10,
          tickFormat: function (seconds) {
            var formatTime = d3.time.format('%H:%M');
            return formatTime(new Date(1864, 7, 7, 0, seconds));
          }
        },
        x: function (d) { return d.hour; },
        y: function (d) { return d.calls; }
      }
    };

    vm.data = [{
      'key': 'Jonotusaika',
      'values': []
    }];

    function fetchContactStats() {
      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;

        var queueDurationsByTimes = data.queue_durations_by_times
          .map(function (j) {
            return { hour: new Date(j[0]).getTime(), calls: j[1] };
          });
        vm.data[0].values = queueDurationsByTimes;
      });
    }

    var fetchContactStatsInterval = $interval(fetchContactStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchContactStats();
  });
