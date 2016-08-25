angular.module('ocWebGui.shared.chart.service', ['ocWebGui.shared.time.service'])
  .factory('Chart', function (CustomDate) {
    return {
      queueChart: {
        chart: {
          type: 'linePlusBarChart',
          height: 500,
          margin: {
            top: 30,
            right: 130,
            bottom: 30,
            left: 100
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
            showMaxMin: true,
            axisLabelDistance: 20,
          },
          y1Axis: {
            axisLabel: 'Puheluja tunnissa',
            axisLabelDistance: 20,
          },
          y2Axis: {
            axisLabel: 'Keskim. jonotusaika',
            axisLabelDistance: 30,
            tickFormat: function (seconds) {
              return CustomDate.niceFormatting(seconds);
            }
          },
          showLegend: false,
          duration: 500
        }
      },

      scatterOptions: {
        chart: {
          type: 'scatterChart',
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
            tickFormat: function (seconds) {
              return CustomDate.niceFormatting(seconds);
            }
          },
          yAxis: {
            axisLabel: 'Jonotusaika',
            axisLabelDistance: 10,
            tickFormat: function (seconds) {
              return CustomDate.niceFormatting(seconds);
            }
          },
          x: function (d) { return d.hour; },
          y: function (d) { return d.calls; },
          showLegend: false
        }
      },

      multiChartOptions: {
        chart: {
          type: 'multiChart',
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
            axisLabel: 'Jonotusaika',
            tickFormat: function (seconds) {
              return CustomDate.niceFormatting(seconds);
            }
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
