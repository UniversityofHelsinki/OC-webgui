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
    vm.scatterOptions = ChartJuttu.scatterOptions;

    vm.scatterData = [{
      'key': 'Jonotusaika',
      'values': []
    }];

    vm.multiChartApi = {};
    vm.multiChartOptions = ChartJuttu.multiChartOptions;

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
            .filter(function (item) { return item.hour >= vm.otherSettings.working_day_start && item.hour <= vm.otherSettings.working_day_end; });
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
