angular.module('ocWebGui.queue', ['ocWebGui.queue.service', 'ui.router', 'ocWebGui.shared.time', 'nvd3'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('queue', {
        url: '/queue',
        templateUrl: 'queue/_queue.html',
        controller: 'QueueController',
        controllerAs: 'queue'
      });
  })
  .controller('QueueController', function ($interval, $scope, Queue) {
    var vm = this;

    vm.options = {
      chart: {
        type: 'multiChart',
        height: 250,
        margin: {
          top: 30,
          right: 40,
          bottom: 60,
          left: 40
        },
        color: d3.scale.category20().range(),
        transitionDuration: 500,
        xAxis: {
          tickFormat: function(d) {
            return d3.format(',f')(d);
          },
          ticks: 20,
          // tickValues: [5, 7, 10, 15, 20]
        },
        yAxis1: {
          tickFormat: function(d) {
            return d3.format(',.1f')(d);
          }
        },
        yAxis2: {
          tickFormat: function(d) {
            return d3.format(',.1f')(d);
          }
        },
        yDomain1: [0,1.111],
        yDomain2: [0,33]
      }
    };

    vm.data = [{"key": "toine vaa",
                "values": [
                  {"x":0,"y":5.5},{"x":1,"y":12},
                  {"x":2,"y":1.4},{"x":3,"y":2},
                  {"x":4,"y":1.9},{"x":5,"y":11},
                  {"x":6,"y":3.23},{"x":7,"y":7},
                  {"x":8,"y":12.15},{"x":9,"y":4},
                  {"x":10,"y":11.14},{"x":11,"y":3},
                  {"x":12,"y":4.12},{"x":13,"y":13},
                  {"x":14,"y":7.2},{"x":15,"y":1},
                  {"x":16,"y":3.7},{"x":17,"y":20},
                  {"x":18,"y":0.15},{"x":19,"y":0.2},
                  {"x":20,"y":3.0},{"x":21,"y":13},
                  {"x":22,"y":1.2},{"x":23,"y":0.12}],
                "type": "line",
                "yAxis": 2},

                {"key": "joku", 
                 "values": [
                  {"x":0,"y":0.11974798073123002},{"x":1,"y":0.1895057559421199},
                  {"x":2,"y":0.10314504511908851},{"x":3,"y":0.1666229648632272},
                  {"x":4,"y":0.1887995123186846},{"x":5,"y":0.3035997203729298},
                  {"x":6,"y":0.6473198551192336},{"x":7,"y":0.121955039397465},
                  {"x":8,"y":0.4394235666363644},{"x":9,"y":0.3594654668035855},
                  {"x":10,"y":0.9613337594176934},{"x":11,"y":0.5305646554680374},
                  {"x":12,"y":0.28820972725225835},{"x":13,"y":0.23525337105928737},
                  {"x":14,"y":0.3877272758522322},{"x":15,"y":0.2695719616482999},
                  {"x":16,"y":0.0703105522401684},{"x":17,"y":0.510300398752299},
                  {"x":18,"y":0.034558748435663},{"x":19,"y":0.119299364017256},
                  {"x":20,"y":1.604822456569353},{"x":21,"y":0.704119424540316},
                  {"x":22,"y":0.0235378351670104},{"x":23,"y":0.3092114658958694}], 
                 "type": "bar",
                 "yAxis": 1}];
   
    // arvon asettaminen
    // vm.data[0]["values"][2]["y"] = 33;
    // tai tälleen
    // vm.data[0]["values"].push({"x": 27, "y": 11.11});
    
    var fetchDataInterval;
    
    vm.message = 'Jono';

    vm.queue = [];

    vm.date = new Date();

    function fetchData() {
      Queue.query(function (queue) {
        vm.queue = queue.filter(function (queuer) {
          return queuer.language !== 'Unknown';
        });
      });
      // Also update date/time
      vm.date = new Date();
    }

    fetchDataInterval = $interval(fetchData, 5000);
    $scope.$on('$destroy', function () {
      $interval.cancel(fetchDataInterval);
    });

    fetchData();

    // mock data for testing css
    // vm.queue = [
    //   { line: 135, language: 'Fin', time_in_queue: 360 },
    //   { line: 137, language: 'Fin', time_in_queue: 123 },
    //   { line: 125, language: 'Eng', time_in_queue: 123 },
    //   { line: 137, language: 'Fin', time_in_queue: 123 },
    //   { line: 133, language: 'Swe', time_in_queue: 53  },
    //   { line: 131, language: 'Eng', time_in_queue: 123 },
    //   { line: 121, language: 'Eng', time_in_queue: 214 }
    // ];
  });
