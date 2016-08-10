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
        'type': 'bar',
        'xAxis': 1,
        'yAxis': 1,
        'key': 'Vapaa',
        'color': '#37c837',
        'values': []
      },
      {
        'type': 'bar',
        'xAxis': 1,
        'yAxis': 1,
        'key': 'Puhelu',
        'color': '#ffff4d',
        'values': []
      },
      {
        'type': 'bar',
        'xAxis': 1,
        'yAxis': 1,
        'key': 'Tauolla',
        'color': '#f33',
        'values': []
      },
      {
        'type': 'line',
        'xAxis': 1,
        'yAxis': 2,
        'key': 'Toivonsa menettäneet',
        'color': '#f00',
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
            hour: new Date(d.date).getTime(),
            value: d[name]
          };
        });
      }
    };

    function setData(data, factory) {
      vm.data[0].values = factory(data, 'free');
      vm.data[1].values = factory(data, 'busy');
      vm.data[2].values = factory(data, 'other');

      // Workaround NVD3 because with multi chart type it doesn't get y domain from the stacked bar
      // but individual bars.
      vm.options.chart.yDomain1 = [0, d3.max(data, function (d) {
        return d.free + d.busy + d.other;
      })];
    }

    vm.fetchData = function () {
      AgentStatusStats.stats(vm.startDate, vm.endDate, vm.reportType).then(function (response) {
        setData(response.data.stats, factories[vm.reportType]);
        if (vm.reportType === 'day') {
          vm.data[3].values = response.data.dropped.map(function (d, i) {
            return {
              hour: i,
              value: d
            };
          }).slice(7, 17);
        } else if (vm.reportType === 'month') {
          vm.data[3].values = response.data.dropped.map(function (d) {
            return {
              hour: new Date(d.date).getTime(),
              value: d.count
            };
          });
        }
      });
    };

    vm.options = StatusChart.options();
  });
