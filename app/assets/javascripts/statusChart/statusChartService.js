angular.module('ocWebGui.statusChart.service', ['ngResource'])
  .factory('AgentStatusStats', function ($http) {
    return {
      stats: function (startDate, endDate, onSuccess, onError, reportType) {
        $http.post('agent_statuses/stats', { report_type: reportType,
                                             team_name: 'Helpdesk',
                                             start_date: startDate,
                                             end_date: endDate
                                           })
        .then(function (response) {
          onSuccess(response.data);
        }, function (response) {
          onError(response.data);
        });
      }
    };
  })
  .factory('StatusChart', function () {
    return {
      options: function () {
        return {
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
            xAxis: {
              tickFormat: function (hour) {
                return hour;
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
      }
    };
  });
