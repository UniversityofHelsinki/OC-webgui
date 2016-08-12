angular.module('ocWebGui.others.service', ['ngResource'])
  .factory('Others', function () {    
    return {
      sla_data: {
        sla_time: 300,
        working_day_end: 18,
        working_day_start: 8
      },
      saveData: function(data) {
        sla_data = data;
      },
      getData: function() {
        return sla_data;
      }
    }
  });