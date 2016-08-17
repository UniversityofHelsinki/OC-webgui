angular.module('ocWebGui.stats.status2', ['ui.router', 'ocWebGui.stats.status2.service',
    'ocWebGui.stats.status2.directive'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats.status2', {
        url: '/status2',
        templateUrl: 'stats/status/_status.html',
        controller: 'StatusController2',
        controllerAs: 'status'
      });
  })
  .controller('StatusController2', function (AgentStatusStats) {
    var vm = this;
    vm.reportType = 'day';
    vm.chartData = null;

    vm.fetchData = function () {
      AgentStatusStats.stats(vm.startDate, vm.endDate, vm.reportType).then(function (response) {
        vm.chartData = {
          type: vm.reportType,
          values: response.data
        };
      });
    };

    vm.getCSVData = function () {
      if (vm.reportType === 'day') {
        return vm.chartData.values.stats.map(function (d) {
          return {
            hour: d.hour,
            busy: d.busy,
            free: d.free,
            other: d.other
          };
        });
      }

      if (vm.reportType === 'month') {
        return vm.chartData.values.stats.map(function (d) {
          return {
            date: d.date,
            busy: d.busy,
            free: d.free,
            other: d.other
          };
        });
      }
    };

    vm.getCSVHeader = function () {
      if (vm.reportType === 'day') {
        return ["hour", "busy", "free", "other"];
      }
      return ["date", "busy", "free", "other"];
    };

    vm.getCSVFilename = function () {
      return "stats_by_" + vm.reportType + "_" + vm.startDate + "_" + vm.endDate;
    };
  });
