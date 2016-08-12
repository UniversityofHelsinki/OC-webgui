angular.module('ocWebGui.statusChart.directive', [])
  .directive('ocStatusChart', function (CustomDate, Chart) {
    return {
      restrict: 'E',
      scope: {
        data: '=',
        type: '='
      },
      template: '<nvd3 options="options" data="newData" api="api" class="status-chart"></nvd3>',
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
            lines: {
              padData: true
            },
            x: function (d) { return d.hour; },
            y: function (d) { return d.value; },
            xAxis: {
            },
            yAxis1: {
              tickFormat: function (seconds) {
                return CustomDate.niceFormatting(seconds);
              }
            },
            yAxis2: {
            },
            yDomain1: [0, 10],
            yDomain2: [0, 10],
            noData: 'Ei tilastotietoa',
            // useInteractiveGuideline: true
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
            'color': '#a0a',
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
          var yDomain1Max = d3.max(data, function (d) {
            return d.free + d.busy + d.other;
          }) || 1;
          $scope.options.chart.yDomain1 = [0, yDomain1Max];
        };

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
            $scope.options.chart.xAxis.tickFormat = function (d) { return d; };
          } else if (newData.type === 'month') {
            $scope.newData[3].values = newData.values.dropped.map(function (d) {
              return {
                hour: new Date(d.date).getTime(),
                value: d.count
              };
            });
            $scope.options.chart.xAxis.tickFormat = function (seconds) { return d3.time.format('%d.%m %a')(new Date(seconds)); };
          }
          var queueMax = d3.max($scope.newData[3].values, function (x) { return x.value; }) + 1;
          var callMax = $scope.options.chart.yDomain1[1];
          var y1AxisOldTicks = $scope.options.chart.yAxis1.tickValues;
          var y2AxisOldTicks = $scope.options.chart.yAxis2.tickValues;
          var y1AxisNewTicks = [callMax / 4, callMax / 2, callMax / (1 + 1.0 / 3)];
          var y2AxisNewTicks = [queueMax / 4, queueMax / 2, queueMax / (1 + 1.0 / 3)];
          if (!angular.equals(y1AxisOldTicks, y1AxisNewTicks) || !angular.equals(y2AxisOldTicks, y2AxisNewTicks)) {
            $scope.options.chart.yDomain1[1] = callMax;
            $scope.options.chart.yDomain2[1] = queueMax;
            $scope.options.chart.yAxis1.tickValues = y1AxisNewTicks;
            $scope.options.chart.yAxis2.tickValues = y2AxisNewTicks;
            $scope.api.refresh();
          }
        });
      }
    };
  });
