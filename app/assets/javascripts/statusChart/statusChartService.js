angular.module('ocWebGui.statusChart.service', ['ngResource'])
  .factory('AgentStatusStats', function ($http) {
    return {
      statsByHour: function (startDate, endDate, onSuccess, onError) {
        $http.post('agent_statuses/stats', { team_name: 'Helpdesk',
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
  });
