angular.module('ocWebGui.queue', ['ui.router', 'ngResource'])
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
        $scope.queue = $resource('queue.json').query();
    })
    .filter('secondsToDateTime', [function() {
    return function(seconds) {
        return new Date(1970, 0, 1).setSeconds(seconds);
    };
}])
