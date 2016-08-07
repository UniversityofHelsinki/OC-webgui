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
  .controller('StatusChartController', function StatusChartController($scope, AgentStatusStats) {
    var vm = this;
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
      var stats = data.stats_by_hour;
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
    };

    vm.fetchData = function () {
      AgentStatusStats.statsByHour(vm.startDate, vm.endDate, onSuccess, onSuccess);
    };

    vm.options = {
      chart: {
        type: 'multiBarChart',
        height: 600,
        margin: {
          left: 150
        },
        showControls: false,
        stacked: true,
        fillOpacity: 0.9,
        x: function (d) { return d.hour; },
        y: function (d) { return d.value; },
        x1Axis: {
          tickFormat: function (d) {
            return d3.format(',f')(d);
          }
        },
        yAxis: {
          tickFormat: function (seconds) {
            var hours = Math.floor(seconds / 3600);
            var mins = Math.floor(seconds % 3600 / 60);
            var secs = seconds % 3600 % 60;
            return hours + ':' + mins + ':' + secs;
          }
        }
      }
    };
  });
