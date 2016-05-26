angular.module('ocWebGui.home', ['ui.router'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('home', {
                url: '/home',
                templateUrl: 'home/_home.html',
                controller: 'HomeController'
            });
        $urlRouterProvider.otherwise('home');
    })
    .controller('HomeController', function() {
    });
