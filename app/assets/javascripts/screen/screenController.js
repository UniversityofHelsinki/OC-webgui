angular.module('ocWebGui.screen', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Hei maailma!';

        $interval(function() {
            $scope.users = $resource('http://localhost:3000/testis.json').query();
        }, 1000);
    });
