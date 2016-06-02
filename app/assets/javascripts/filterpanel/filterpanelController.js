angular.module('ocWebGui.filterpanel', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('filterpanel', {
                url: '/filterpanel',
                templateUrl: 'filterpanel/_filterpanel.html',
                controller: 'filterpanelController'
            });
    })
    .controller('filterpanelController', function($resource, $interval, $scope) {
        $scope.message = 'Tilat-- ..';
    });
