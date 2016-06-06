angular.module('ocWebGui.screen', ['ui.router', 'ngResource', 'ocWebGui.shared.time', 'ocWebGui.filterpanel'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .controller('ScreenController', function($resource, $interval, $scope, shared) {
        $scope.teams = shared.getTeams();
        $scope.states = shared.getStates();
        $scope.message = 'Tilat';
        $scope.agents = [];

        function fetchData() {
            $resource('agents.json').query(function(agents) {
                $scope.agents = agents.filter(function(agent) {
                    return (($scope.states[agent.status] == true)
                        && ($scope.teams[agent.team] == true));
                });
            });
        }

        var fetchDataInterval = $interval(fetchData, 5000);
        $scope.$on('$destroy', function() {
            $interval.cancel(fetchDataInterval);
        });

        fetchData();
    });
