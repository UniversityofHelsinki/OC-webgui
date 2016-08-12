angular.module('ocWebGui.others.service', ['ngResource'])
  .factory('Others', function () {    
    return {
      sla_data: {
        sla_time: 300,
        working_day_end: 18,
        working_day_start: 8
      },
      saveData: function(data) {        
        this.sla_data.sla_time = data.sla;
        this.working_day_end = data.working_day_end;
        this.working_day_start = data.working_day_start;        
      },
      getData: function() {       
        return sla_data;
      }
    }
  });