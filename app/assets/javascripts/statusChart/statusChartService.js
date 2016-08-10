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
  });
