angular.module('ocWebGui.queue', ['ui.router', 'ngResource', 'ocWebGui.shared.time'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('queue', {
                url: '/queue',
                templateUrl: 'queue/_queue.html',
                controller: 'QueueController'
            });
    })
    .controller('QueueController', function($resource, $interval, $scope) {
        $scope.message = 'Jono';

        $scope.queue = [];

        function fetchData() {
            $resource('queue.json').query(function (data) {
                $scope.queue = data;
            });
        }

        var fetchDataInterval = $interval(fetchData, 5000);
        $scope.$on('$destroy', function() {
            $interval.cancel(fetchDataInterval);
        });

        fetchData();
        
        // mock data for testing css
        // $scope.queue = [{line: 135, time_in_queue:360}, {line:137, time_in_queue:123}, {line:125, time_in_queue:123}, {line:137, time_in_queue:123}, {line:133, time_in_queue:123}, {line:137, time_in_queue:123}, {line:121, time_in_queue:123}]
        $scope.language = function(line) {
          switch (line) {
            case 135:
            case 137:
            case 136:
              return "Fin";
            case 125:
            case 131:
            case 121:
              return "Eng";
           case 133:
              return "Swe";
          }
        }
        $scope.date = new Date();
    });
