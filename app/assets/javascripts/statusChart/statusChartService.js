angular.module('ocWebGui.statusChart.service', ['ngResource'])
  .factory('AgentStatusStats', function ($http) {
    return {
      stats: function (startDate, endDate, reportType) {
        return $http.post('agent_statuses/stats', {
          report_type: reportType,
          team_name: 'Helpdesk',
          start_date: startDate,
          end_date: endDate
        });
      }
    };
  })
  .factory('StatusChart', function (CustomDate) {
    return {
      options: function () {
        return {
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
      }
    };
  });
