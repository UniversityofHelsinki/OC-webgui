angular.module('ocWebGui.statusChart.directive', [])
  .directive('ocStatusChart', function (CustomDate) {
    return {
      restrict: 'E',
      scope: {
        data: '=',
        type: '='
      },
      template: '<nvd3 options="options" data="newData" api="api"></nvd3>',
      controller: function ($scope) {
        $scope.api = {};

        $scope.options = {
          chart: {
            type: 'multiChart',
            bars1: {
              stacked: true
            },
            height: 600,
            margin: {
              left: 150
            },
            x: function (d) { return d.hour; },
            y: function (d) { return d.value; },
            yAxis1: {
              tickFormat: function (seconds) {
                return CustomDate.niceFormatting(seconds);
              }
            }
          }
        };

        $scope.newData = [
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
          $scope.newData[0].values = factory(data, 'free');
          $scope.newData[1].values = factory(data, 'busy');
          $scope.newData[2].values = factory(data, 'other');

          // Workaround NVD3 because with multi chart type it doesn't get y domain from the stacked
          // bar but individual bars.
          $scope.options.chart.yDomain1 = [0, d3.max(data, function (d) {
            return d.free + d.busy + d.other;
          })];
        }

        $scope.$watch('data', function (newData) {
          if (!newData.type || !newData.values) {
            return;
          }
          setData(newData.values.stats, factories[newData.type]);
          if (newData.type === 'day') {
            $scope.newData[3].values = newData.values.dropped.map(function (d, i) {
              return {
                hour: i,
                value: d
              };
            }).slice(7, 17);
          } else if (newData.type === 'month') {
            $scope.newData[3].values = newData.values.dropped.map(function (d) {
              return {
                hour: new Date(d.date).getTime(),
                value: d.count
              };
            });
          }
        });
      }
    };
  });
