angular.module('ocWebGui.screen', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .filter('secondsToDateTime', [function() {
        return function(seconds) {
            return new Date(1970, 0, 1).setSeconds(seconds);
        };
    }])
    .controller('ScreenController', function($resource, $scope, shared) {
        $scope.teams = shared.getTeams();
        $scope.states = shared.getStates();
        $scope.message = 'Tilat';
        $resource('agents.json').query(function(agents) {
          
          $scope.agents = agents.filter(function(agent) {
              return (($scope.states[agent.status] == true)
                  && ($scope.teams[agent.team] == true));
          });
        });
    });
