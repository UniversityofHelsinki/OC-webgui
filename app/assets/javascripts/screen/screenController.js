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

        $scope.agents = [];

        function fetchData() {
            $scope.agents = $resource('agents.json').query();
        }

        var fetchDataInterval = $interval(fetchData, 5000);
        $scope.$on('$destroy', function() {
            $interval.cancel(fetchDataInterval);
        });

        fetchData();
    });
