angular.module('ocWebGui.screen', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('screen', {
                url: '/screen',
                templateUrl: 'screen/_screen.html',
                controller: 'ScreenController'
            });
    })
    .controller('ScreenController', function($resource, $interval, $scope) {
        $scope.message = 'Tilat';
        $scope.teams = ["Hakijapalvelut", "Helpdesk", "Opiskelijaneuvonta", "OrangeContact 1", "Puhelinvaihde", "Uaf"];
        $scope.agents = $resource('agents.json').query();
    })

    .controller('SimpleArrayCtrl', ['$scope', function SimpleArrayCtrl($scope) {
      $scope.teams = ["Hakijapalvelut", "Helpdesk", "Opiskelijaneuvonta", "OrangeContact 1", "Puhelinvaihde", "Uaf"];
      $scope.selection = ["Helpdesk"];
      $scope.toggleSelection = function toggleSelection(team) {
        var idx = $scope.selection.indexOf(team);
        if (idx > -1) {
          $scope.selection.splice(idx, 1);
        }
        else {
          $scope.selection.push(team);
        }
      };
    }]);
