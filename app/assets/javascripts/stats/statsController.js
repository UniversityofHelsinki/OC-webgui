angular.module('ocWebGui.stats', ['ui.router', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats', {
        url: '/stats',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'stats/_stats.html',
            controller: 'StatsController',
            controllerAs: 'stats'
          }
        }
      });
  })
  .controller('StatsController', function ($interval, $scope, $http, Settings, ChartJuttu) {
    var vm = this;
    vm.title = 'Tilastot';

    vm.api = {};
    vm.options = {
      chart: {
        type: 'scatterChart',
        width: 700,
        height: 300,
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
          left: 90
        },
        x: function (d) { return d.hour; },
        y: function (d) { return d.calls; },
        duration: 500,
        xAxis: {
          axisLabel: 'Kellonaika'
        },
        yAxis1: {
          axisLabel: 'Jonottajat',
          yDomain: [0, 10]
        },
        yAxis2: {
          axisLabel: 'Aikaa',
          tickFormat: function (seconds) {
            var formatTime = d3.time.format('%H:%M');
            return formatTime(new Date(1864, 7, 7, 0, seconds));
          },
          yDomain: [0, 10]
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
    }, {
      'key': 'Palvelutaso',
      'values': [],
      'type': 'line',
      'yAxis': 2,
      'color': '#ff0000'
    }];

    function fetchContactStats() {
      Settings.getOthers().then(function (others) {
        vm.otherSettings = others;
      });

      $http.get('contacts/stats.json').then(function (response) {
        var data = response.data;
        var beginningOfDay = new Date();
        beginningOfDay.setDate(beginningOfDay.getDate());
        beginningOfDay.setHours(8, 0, 0);

        var endOfDay = new Date();
        endOfDay.setDate(endOfDay.getDate());
        endOfDay.setHours(18, 0, 0);

        var queueDurationsByTimes = data.queue_durations_by_times
          .map(function (j) { return { hour: new Date(j[0]).getTime(), calls: j[1] }; });
        vm.data[0].values = queueDurationsByTimes;

        vm.options.chart.xAxis.tickValues = d3.time.hour.range(beginningOfDay, endOfDay, 1)
          .map(function (f) { return f.getTime(); });
        vm.api.refresh();

        var callsByHours = ChartJuttu.mapAndFilter(data.calls_by_hour, vm.otherSettings);
        var missedCallsByHours = ChartJuttu.mapAndFilter(data.missed_calls_by_hour, vm.otherSettings);
        var averageQueueDurationByHour = ChartJuttu.mapAndFilter(data.average_queue_duration_by_hour, vm.otherSettings);

        vm.data2[0].values = callsByHours;
        vm.data2[1].values = missedCallsByHours;
        vm.data2[2].values = averageQueueDurationByHour;

        // use 0 because all calls is always same or bigger than missed calls
        var callMax = ChartJuttu.getMaxValPlusOne(vm.data2[0]);
        // Multiply by 1.05 so highest value is high enough that highest point in chart isn't hidden
        var queueMax = ChartJuttu.getMaxValPlusOne(vm.data2[2]) * 1.05;

        var sla = 300;
        if (sla <= queueMax) {
          var slaLine = data.calls_by_hour
            .map(function (calls, hour) { return { hour: hour, calls: sla }; })
            .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });
          vm.data2[3].values = slaLine;
        }

        vm.options2.chart.yAxis1.yDomain = callMax;
        vm.options2.chart.yAxis2.yDomain = queueMax;
        var yAxis1OldTicks = vm.options2.chart.yAxis1.tickValues;
        var yAxis2OldTicks = vm.options2.chart.yAxis2.tickValues;
        var yAxis1NewTicks = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
        var yAxis2NewTicks = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
        if (!angular.equals(yAxis1OldTicks, yAxis1NewTicks) || !angular.equals(yAxis2OldTicks, yAxis2NewTicks)) {
          vm.options2.chart.yAxis1.tickValues = yAxis1NewTicks;
          vm.options2.chart.yAxis2.tickValues = yAxis2NewTicks;
          vm.api2.refresh();
        }
      });
    }

    var fetchContactStatsInterval = $interval(fetchContactStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchContactStats();
  });
