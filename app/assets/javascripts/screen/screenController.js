angular.module('ocWebGui.screen', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .filter('secondsToDateTime', [function() {
        return function(seconds) {
            return new Date(1970, 0, 1).setSeconds(seconds);
        };
    }])
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Tilat';
        
        var agents = $resource('agents.json').query();
        
        console.log(agents);
        
        $scope.agents = agents;
    });