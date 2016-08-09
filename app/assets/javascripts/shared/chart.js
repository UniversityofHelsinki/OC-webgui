angular.module('ocWebGui.shared.chart.service', [])
  .factory('Chart', function () {
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
          pointSize: 200,
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
          yAxis1: {
          },
          yAxis2: {
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

      scatterOptions: {
        chart: {
          type: 'scatterChart',
          width: 700,
          height: 300,
          margin: {
            top: 30,
            right: 90,
            bottom: 60,
            left: 90
          },
          pointRange: [100, 100],
          color: d3.scale.category10().range(),
          noData: 'Ei tilastotietoa tälle päivälle',
          showDistX: true,
          showDistY: true,
          xAxis: {
            axisLabel: 'Kellonaika',
            tickFormat: function (currentSeconds) {
              var pad2 = function (value) { return (value < 10 ? '0' : '') + value; };
              var seconds = currentSeconds % 60;
              var minutes = Math.floor(currentSeconds / 60 % 60);
              var hours = Math.floor(currentSeconds / 60 / 60);
              return pad2(hours) + ':' + pad2(minutes) + ':' + pad2(seconds);
            }
          },
          yAxis: {
            axisLabel: 'Jonotusaika',
            axisLabelDistance: 10,
            tickFormat: function (seconds) {
              var formatTime = d3.time.format('%H:%M');
              return formatTime(new Date(1864, 7, 7, 0, seconds));
            }
          },
          x: function (d) { return d.hour; },
          y: function (d) { return d.calls; }
        }
      },

      multiChartOptions: {
        chart: {
          type: 'multiChart',
          width: 700,
          height: 550,
          margin: {
            top: 30,
            right: 90,
            bottom: 60,
            left: 90
          },
          x: function (d) { return d.hour; },
          y: function (d) { return d.calls; },
          duration: 500,
          useInteractiveGuideline: true,
          xAxis: {
            axisLabel: 'Kellonaika'
          },
          yAxis1: {
            axisLabel: 'Jonottajat',
          },
          yAxis2: {
            axisLabel: 'Aikaa',
            tickFormat: function (seconds) {
              var formatTime = d3.time.format('%H:%M');
              return formatTime(new Date(1864, 7, 7, 0, seconds));
            },
          },
          yDomain1: [0, 10],
          yDomain2: [0, 10]
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
