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

    vm.api2 = {};
    vm.options2 = {
      chart: {
        type: 'multiChart',
        width: 700,
        height: 550,
        margin: {
          top: 30,
          right: 90,
          bottom: 60,
          left: 40
        },
        duration: 500,
        xAxis: {
          axisLabel: 'Kellonaika',
          tickFormat: function (d) {
            return d3.time.format('%H.%M')(new Date(d));
          }
        },
        yAxis2: {
          ticks: 10,
          tickFormat: function (seconds) {
            var formatTime = d3.time.format('%H:%M');
            return formatTime(new Date(1864, 7, 7, 0, seconds));
          }
        }
      }
    };

    vm.data2 = [{
      'key': 'Henkilöitä',
      'values': [],
      'type': 'line',
      'yAxis': 1,
      'color': '#ff00ff'
    }, {
      'key': 'Luopuneet',
      'values': [],
      'type': 'area',
      'yAxis': 1,
      'color': '#0000ff'
    }, {
      'key': 'Jonotuksen keskiarvo',
      'values': [],
      'type': 'bar',
      'yAxis': 2,
      'color': '#00ff00'
    }];

    function fetchContactStats() {
      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;

        var queueDurationsByTimes = data.queue_durations_by_times
          .map(function (j) { return { hour: new Date(j[0]).getTime(), calls: j[1] }; });
        vm.data[0].values = queueDurationsByTimes;

        var clock8 = new Date();
        clock8.setDate(clock8.getDate());
        clock8.setHours(8, 0, 0);

        var clock18 = new Date();
        clock18.setDate(clock18.getDate());
        clock18.setHours(18, 0, 0);
        var first = data.correlation_of_average_queue_length_and_missed_calls
          .map(function (j) { return { x: new Date(j[0]).getTime(), y: j[1] }; })
          .filter(function (item) { return item.x >= clock8 && item.x <= clock18; });
        vm.data2[0].values = first;

        var second = data.correlation_of_average_queue_length_and_missed_calls
          .map(function (j) { return { x: new Date(j[0]).getTime(), y: j[2] }; })
          .filter(function (item) { return item.x >= clock8 && item.x <= clock18; });
        vm.data2[1].values = second;

        var third = data.correlation_of_average_queue_length_and_missed_calls
          .map(function (j) { return { x: new Date(j[0]).getTime(), y: j[3] }; })
          .filter(function (item) { return item.x >= clock8 && item.x <= clock18; });
        vm.data2[2].values = third;

        vm.options2.chart.xAxis.tickValues = d3.time.hour.range(clock8, clock18, 1)
          .map(function (f) { return f.getTime() });
      });
    }

    var fetchContactStatsInterval = $interval(fetchContactStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchContactStats();
  });
