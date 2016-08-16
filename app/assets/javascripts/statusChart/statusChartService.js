angular.module('ocWebGui.statusChart.service', ['ngResource'])
  .factory('AgentStatusStats', function ($http) {
    return {
      stats: function (startDate, endDate, reportType) {
        // swap dates other way around if startDate is after endDate
        if (startDate > endDate) {
          [startDate, endDate] = [endDate, startDate]
        }
        return $http.post('agent_statuses/stats', {
          report_type: reportType,
          team_name: 'Helpdesk',
          start_date: startDate,
          end_date: endDate
        });
      }
    };
  });
