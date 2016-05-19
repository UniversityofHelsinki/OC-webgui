angular.module('ocWebGui', ['ngResource'])
    .controller('MainCtrl', ['$resource', '$interval', '$scope', function($resource, $interval, $scope){
        $scope.message = 'Hei maailma!';

        $interval(function() {
        	$scope.users = $resource('http://localhost:3000/testis.json	').query();
        }, 1000);
    }]);

