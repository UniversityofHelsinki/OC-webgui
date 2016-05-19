angular.module('ocWebGui', ['ngResource', 'ui.router', 'templates'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('home', {
                url: '/home',
                templateUrl: 'home.html',
                controller: 'HomeController'
            })
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen.html',
                controller: 'ScreenController'
            });
        $urlRouterProvider.otherwise('home');
    })
    .controller('HomeController', function() {
    })
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Hei maailma!';

        $interval(function() {
            $scope.users = $resource('http://localhost:3000/testis.json').query();
        }, 1000);
    });

