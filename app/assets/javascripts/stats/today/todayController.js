angular.module('ocWebGui.stats.today', ['ocWebGui.stats.today.service', 'ui.router', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats.today', {
        url: '/today',
        templateUrl: 'stats/today/_today.html',
        controller: 'TodayController',
        controllerAs: 'stats'
      });
  })
  .controller('TodayController', function ($q, $interval, $scope, $http, Settings, Chart, Stats) {
    var vm = this;

    vm.scatterApi = {};
    vm.scatterOptions = Chart.scatterOptions;

    vm.scatterData = [{
      'key': 'Jonotusaika',
      'values': []
    }];

    vm.multiChartApi = {};
    vm.multiChartOptions = Chart.multiChartOptions;

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
      Stats.query().then(function (values) {
        vm.otherSettings = values.otherSettings;

        var data = values.response.data;
        var queueDurationsByTimes = data.queue_durations_by_times
          .map(function (j) { return { hour: j[0], calls: j[1] }; });
        vm.scatterData[0].values = queueDurationsByTimes;
//        vm.scatterOptions.chart.xAxis.tickValues = d3.time.hour.range(beginningOfDay, endOfDay, 1)
//          .map(function (f) { return f.getTime(); });
        vm.scatterApi.refresh();

        var callsByHours = Chart.mapAndFilter(data.calls_by_hour, vm.otherSettings);
        var missedCallsByHours = Chart.mapAndFilter(data.missed_calls_by_hour, vm.otherSettings);
        var averageQueueDurationByHour = Chart.mapAndFilter(data.average_queue_duration_by_hour, vm.otherSettings);

        vm.multiChartData[0].values = callsByHours;
        vm.multiChartData[1].values = missedCallsByHours;
        vm.multiChartData[2].values = averageQueueDurationByHour;

        // use 0 because all calls is always same or bigger than missed calls
        var callMax = Chart.getMaxValPlusOne(vm.multiChartData[0]);
        // Multiply by 1.05 so highest value is high enough that highest point in chart isn't hidden
        var queueMax = Chart.getMaxValPlusOne(vm.multiChartData[2]) * 1.05;

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
          vm.multiChartOptions.chart.yDomain1[1] = callMax;
          vm.multiChartOptions.chart.yDomain2[1] = queueMax;
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
