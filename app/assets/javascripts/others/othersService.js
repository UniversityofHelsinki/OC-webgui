angular.module('ocWebGui.others.service', ['ngResource'])
  .factory('Others', function () {
    var sla_time;
      
    function saveData(time) {
        sla_time = time;   
    };
    
    function getTime() {
        return sla_time;
    }
  });