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
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Tilat';
        
        /*
        var agents = $resource('agents.json', {}, {
            'get': {
                method: 'GET',
                params: {},
                isArray: true,
                transformResponse: function(data, header){
                    //Getting string data in response
                    var jsonData = angular.fromJson(data);
                    var notes = [];

                    angular.forEach(jsonData, function(item){
                        var note = new Note();
                        note.noteTitle = item.title;  
                        notes.push(note);
                     });

                    return notes;
                                
                }
            }
        }); */
        
        // Agent status and colors classifications        
        $scope.agents = $resource('agents.json').query(function() {
            var agents = $scope.agents;
            var green = 0;
            var yellow = 0;
            var red = 0;
            
            for(i=0; i< agents.length; i++) {
                if(agents[i].status === "Sisäänkirjaus") {
                    agents[i].color = "green";
                    green++;
                    
                } else if (agents[i].status === "TAUKO") {
                    agents[i].color = "yellow";
                    yellow++;
                    
                } else if(agents[i].status === "TÄYDENNÄ TÄHÄN!!!") {
                    agents[i].color = "red";
                    red++;
                    
                } else {
                    agents[i].color = "black";
                }
            }
            
            $scope.green = green;
            $scope.yellow = yellow;
            $scope.red = red;
        });
    });