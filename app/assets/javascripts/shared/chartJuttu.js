angular.module('ocWebGui.shared.chartJuttu.service', [])
  .factory('ChartJuttu', function () {
    return {
      queueChart: {
        chart: {
          type: 'linePlusBarChart',
          height: 550,
          margin: {
            top: 30,
            right: 70,
            bottom: 40,
            left: 70
          },
          x: function (d) { return d.hour; },
          y: function (d) { return d.calls; },
          bars: {
            forceY: [0, 50],
            yDomain: [0, 10]
          },
          lines: {
            forceY: [0, 50],
            yDomain: [0, 10]
          },
          xAxis: {
            tickFormat: function (d) {
              return d3.format(',f')(d);
            },
            axisLabel: 'Kellonaika',
            showMaxMin: true
          },
          y1Axis: {
          },
          y2Axis: {
            tickFormat: function (seconds) {
              var formatTime = d3.time.format('%H:%M');
              return formatTime(new Date(1864, 7, 7, 0, seconds));
            }
          },
          legend: {
            maxKeyLength: 100
          },
          duration: 500
        }
      },

      mapAndFilter: function (data, settings) {
        return data
          .map(function (calls, hour) { return { hour: hour, calls: calls }; })
          .filter(function (item) { return item.hour >= settings.working_day_start && item.hour <= settings.working_day_end; });
      },

      getMaxValPlusOne: function (w) {
        var maxVal = d3.max(w.values, function (x) { return x.calls; });
        if (maxVal == null) {
          return 1;
        }
        return maxVal + 1;
      }
    };
  });
