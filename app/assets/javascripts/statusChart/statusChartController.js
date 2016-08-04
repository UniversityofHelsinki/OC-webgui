angular.module('ocWebGui.statusChart', ['ui.router'])
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
  .controller('StatusChartController', function StatusChartController($scope) {
    var vm = this;
    vm.api = {};
    vm.data = [{
      'key': 'Vapaa',
      'color': '#f33',
      'values': [{ a: 'jan', b: 4 }, { a: 'feb', b: 6 }, { a: 'mar', b: 2 }]
    },
    {
      'key': 'Puhelu',
      'color': '#ffff4d',
      'values': [{ a: 'jan', b: 2 }, { a: 'feb', b: 2 }, { a: 'mar', b: 4  }]
    },
    {
      'key': 'Tauolla',
      'color': '#37c837',
      'values': [{ a: 'jan', b: 2 }, { a: 'feb', b: 4 }, { a: 'mar', b: 4 }]
    }];

    vm.options = {
      chart: {
        type: 'multiBarChart',
        height: 600,
        showControls: false,
        stacked: true,
        fillOpacity: 0.9,
        x: function (d) { return d.a; },
        y: function (d) { return d.b; },
        x1Axis: {
          tickFormat: function (d) {
            return d3.format(',f')(d);
          }
        },
        yAxis: {
          tickFormat: function (d) {
            return d3.format(',.1f')(d);
          }
        }
      }
    };
  });
