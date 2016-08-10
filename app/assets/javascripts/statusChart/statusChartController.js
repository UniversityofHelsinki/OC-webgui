angular.module('ocWebGui.statusChart', ['ui.router', 'ocWebGui.statusChart.service',
    'ocWebGui.statusChart.directive'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('statusChart', {
        url: '/statusChart',
        views: {
          nav: {
            templateUrl: 'navbar/navbar_others.html'
          },
          content: {
            templateUrl: 'statusChart/_statusChart.html',
            controller: 'StatusChartController',
            controllerAs: 'statusChart'
          }
        }
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
  });
