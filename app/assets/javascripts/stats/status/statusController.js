angular.module('ocWebGui.stats.status', ['ui.router', 'ocWebGui.stats.status.service',
    'ocWebGui.stats.status.directive'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('stats.status', {
        url: '/status',
        templateUrl: 'stats/status/_status.html',
        controller: 'StatusChartController',
        controllerAs: 'status'
      });
  })
  .controller('StatusChartController', function (AgentStatusStats) {
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
        return ['hour', 'busy', 'free', 'other'];
      }
      return ['date', 'busy', 'free', 'other'];
    };

    vm.getCSVFilename = function () {
      return 'stats_by_' + vm.reportType + '_' + vm.startDate + '_' + vm.endDate;
    };
  });
