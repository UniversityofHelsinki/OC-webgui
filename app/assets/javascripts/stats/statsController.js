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

    vm.scatterApi = {};
    vm.scatterOptions = {
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

    vm.scatterData = [{
      'key': 'Jonotusaika',
      'values': []
    }];

    vm.multiChartApi = {};
    vm.multiChartOptions = {
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

    vm.multiChartData = [{
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
        beginningOfDay.setHours(vm.otherSettings.working_day_start, 0, 0);
        var endOfDay = new Date();
        endOfDay.setDate(endOfDay.getDate());
        endOfDay.setHours(vm.otherSettings.working_day_end, 0, 0);

        var queueDurationsByTimes = data.queue_durations_by_times
          .map(function (j) { return { hour: new Date(j[0]).getTime(), calls: j[1] }; });
        vm.scatterData[0].values = queueDurationsByTimes;

        vm.scatterOptions.chart.xAxis.tickValues = d3.time.hour.range(beginningOfDay, endOfDay, 1)
          .map(function (f) { return f.getTime(); });
        vm.scatterApi.refresh();

        var callsByHours = ChartJuttu.mapAndFilter(data.calls_by_hour, vm.otherSettings);
        var missedCallsByHours = ChartJuttu.mapAndFilter(data.missed_calls_by_hour, vm.otherSettings);
        var averageQueueDurationByHour = ChartJuttu.mapAndFilter(data.average_queue_duration_by_hour, vm.otherSettings);

        vm.multiChartData[0].values = callsByHours;
        vm.multiChartData[1].values = missedCallsByHours;
        vm.multiChartData[2].values = averageQueueDurationByHour;

        // use 0 because all calls is always same or bigger than missed calls
        var callMax = ChartJuttu.getMaxValPlusOne(vm.multiChartData[0]);
        // Multiply by 1.05 so highest value is high enough that highest point in chart isn't hidden
        var queueMax = ChartJuttu.getMaxValPlusOne(vm.multiChartData[2]) * 1.05;

        var sla = 300;
        if (sla <= queueMax) {
          var slaLine = data.calls_by_hour
            .map(function (calls, hour) { return { hour: hour, calls: sla }; })
            .filter(function (item) { return item.hour >= 8 && item.hour <= 18; });
          vm.multiChartData[3].values = slaLine;
        }

        vm.multiChartOptions.chart.yAxis1.yDomain = callMax;
        vm.multiChartOptions.chart.yAxis2.yDomain = queueMax;
        var yAxis1OldTicks = vm.multiChartOptions.chart.yAxis1.tickValues;
        var yAxis2OldTicks = vm.multiChartOptions.chart.yAxis2.tickValues;
        var yAxis1NewTicks = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
        var yAxis2NewTicks = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
        if (!angular.equals(yAxis1OldTicks, yAxis1NewTicks) || !angular.equals(yAxis2OldTicks, yAxis2NewTicks)) {
          vm.multiChartOptions.chart.yAxis1.tickValues = yAxis1NewTicks;
          vm.multiChartOptions.chart.yAxis2.tickValues = yAxis2NewTicks;
          vm.multiChartApi.refresh();
        }
      });
    }

    var fetchContactStatsInterval = $interval(fetchContactStats, 5 * 60 * 1000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchContactStatsInterval);
    });

    fetchContactStats();
  });
