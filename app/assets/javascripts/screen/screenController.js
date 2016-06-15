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
        $scope.green = 0;
        $scope.yellow = 0;
        $scope.red = 0;

        function fetchData() {
            $resource('agents.json').query(function(agents) {
                var green = 0;
                var yellow = 0;
                var red = 0;
                
                $scope.agents = agents.filter(function(agent) {
                    return (($scope.states[agent.status] == true)
                        && ($scope.teams[agent.team] == true));
                });
            
                // Agent status coloring and number tally.
                $scope.agents = $scope.agents.map(function(agent) {
                    if(agent.status === "Sisäänkirjaus") {
                        agent.color = "green";
                        green++;
                                    
                    } else if (agent.status === "JÄLKIKIRJAUS") {
                        agent.color = "yellow";
                        yellow++;
                    
                    } else {
                        agent.color = "red";
                        red++;
                    
                    }
                    
                    return agent;
                });
            
                $scope.green = green;
                $scope.yellow = yellow;
                $scope.red = red;
                
            });
            
        }

        var fetchDataInterval = $interval(fetchData, 5000);
        $scope.$on('$destroy', function() {
            $interval.cancel(fetchDataInterval);
        });

        fetchData();
    });
