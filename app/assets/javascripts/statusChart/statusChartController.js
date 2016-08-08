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
  .controller('StatusChartController', function (AgentStatusStats, StatusChart) {
    var vm = this;
    vm.reportType = 'day';
    vm.api = {};
    vm.data = [
      {
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
      }
    ];

    var factories = {
      'day': function (data, name) {
        return data.slice(7, 17).map(function (d) {
          return {
            hour: d.hour,
            value: d[name]
          };
        });
      },
      'month': function (data, name) {
        return data.map(function (d) {
          return {
            hour: d.date,
            value: d[name]
          };
        });
      }
    };

    function setData(data, factory) {
      vm.data[0].values = factory(data, 'free');
      vm.data[1].values = factory(data, 'busy');
      vm.data[2].values = factory(data, 'other');
    }

    vm.fetchData = function () {
      AgentStatusStats.stats(vm.startDate, vm.endDate, vm.reportType).then(function (response) {
        setData(response.data.stats, factories[vm.reportType]);
      });
    };

    vm.options = StatusChart.options();
  });
