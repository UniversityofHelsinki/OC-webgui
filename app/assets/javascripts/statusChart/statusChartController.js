angular.module('ocWebGui.statusChart', ['ui.router', 'ocWebGui.statusChart.service'])
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
  .controller('StatusChartController', function StatusChartController($scope, AgentStatusStats, StatusChart) {
    var vm = this;
    vm.reportType = 'day';
    vm.api = {};
    vm.data = [{
      'key': 'Vapaa',
      'color': '#37c837',
      'values': []
    },
    {
      'key': 'Puhelu',
      'color': '#ffff4d',
      'values': []
    },
    {
      'key': 'Tauolla',
      'color': '#f33',
      'values': []
    }];


    var onSuccess = function (data) {
      if (vm.reportType === 'day') {
        var stats = data.stats;
        vm.data[0].values = [];
        vm.data[1].values = [];
        vm.data[2].values = [];
        for (var i = 0; i < 17; i++) {
          vm.data[0].values[i] = {};
          vm.data[1].values[i] = {};
          vm.data[2].values[i] = {};
          if (i < 8) continue;
          vm.data[0].values[i].hour = i;
          vm.data[0].values[i].value = stats[i].free;
          vm.data[1].values[i].hour = i;
          vm.data[1].values[i].value = stats[i].busy;
          vm.data[2].values[i].hour = i;
          vm.data[2].values[i].value = stats[i].other;
        }
      } else if (vm.reportType === 'month') {
        vm.data[0].values = data.stats.map(function (d) { return { hour: d.date, value: d.free }; });
        vm.data[1].values = data.stats.map(function (d) { return { hour: d.date, value: d.busy }; });
        vm.data[2].values = data.stats.map(function (d) { return { hour: d.date, value: d.other }; });
      }
    };

    vm.fetchData = function () {
      AgentStatusStats.stats(vm.startDate, vm.endDate, onSuccess, onSuccess, vm.reportType);
    };

    vm.options = StatusChart.options();
  });
