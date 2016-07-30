angular.module('ocWebGui.color', ['ui.router', 'ocWebGui.login'])
    .config(function ($stateProvider) {
        $stateProvider
            .state('color', {
                url: '/color',
                templateUrl: 'color/_color.html',
                controller: 'ColorController',
                controllerAs: 'color'
            });
    })
    .controller('ColorController', function ($scope, $http) {
        var vm = this;
        vm.title = 'Värit';
    });
