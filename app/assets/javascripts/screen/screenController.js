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

	$scope.agents = [ {name: "eka", state: "syömässä"}, {name: "toka", state: "puhelimessa"}];
    });
