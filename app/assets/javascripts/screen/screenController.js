angular.module('ocWebGui.screen', ['ui.router', 'ngResource', 'ocWebGui.shared.time'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Tilat';
        $scope.agents = $resource('agents.json').query();
    });
