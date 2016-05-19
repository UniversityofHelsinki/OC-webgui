angular.module('ocWebGui', ['ngResource', 'ui.router', 'templates'])
    .config(['$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('home', {
                url: '/home',
                templateUrl: 'home.html',
                controller: 'HomeCtrl'
            })
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen.html',
                controller: 'ScreenCtrl'
            });
        $urlRouterProvider.otherwise('home');
    }])
    .controller('HomeCtrl', [function(){
    }])
    .controller('ScreenCtrl', ['$resource', '$interval', '$scope', function($resource, $interval, $scope){
        $scope.message = 'Hei maailma!';

        $interval(function() {
        	$scope.users = $resource('http://localhost:3000/testis.json	').query();
        }, 1000);
    }]);

