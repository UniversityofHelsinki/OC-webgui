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

        function fetchData() {
            $resource('agents.json').query(function(agents) {
                $scope.agents = [];
                var green = 0;
                var yellow = 0;
                var red = 0;
                
                $scope.agents = agents.filter(function(agent) {
                    return (($scope.states[agent.status] == true)
                        && ($scope.teams[agent.team] == true));
                });
                
                var agents = $scope.agents;
            
            
                // Agent status coloring and number tally.
                
                agents.map(function(agent) {
                    if(agent.status === "Sisäänkirjaus") {
                        agents[i].color = "green";
                        green++;
                                    
                    } else if (agent.status === "JÄLKIKIRJAUS") {
                        agents[i].color = "yellow";
                        yellow++;
                    
                    } else {
                        agent.color = "red";
                        red++;
                    
                    }
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
