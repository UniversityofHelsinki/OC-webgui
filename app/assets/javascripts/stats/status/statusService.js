angular.module('ocWebGui.stats.status.service', ['ngResource'])
  .factory('AgentStatusStats', function ($http) {
    return {
      stats: function (startDate, endDate, reportType) {
        // swap dates other way around if startDate is after endDate
        if (Date.parse(startDate) > Date.parse(endDate)) {
          [startDate, endDate] = [endDate, startDate];
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
