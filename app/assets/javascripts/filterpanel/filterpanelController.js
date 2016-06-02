angular.module('ocWebGui.filterpanel', ['ui.router', 'ngResource'])
    .config(function($stateProvider, $urlRouterProvider) {
        $stateProvider
            .state('filterpanel', {
                url: '/filterpanel',
                templateUrl: 'filterpanel/_filterpanel.html',
                controller: 'FilterpanelController'
            });
    })
    .controller('FilterpanelController', function FilterpanelController($scope, $rootScope) {
      $scope.teams = ["Hakijapalvelut", "Helpdesk", "Opiskelijaneuvonta", "OrangeContact 1", "Puhelinvaihde", "Uaf"];
      $scope.toggleSelection = function toggleSelection(team) {
        var idx = $rootScope.selection.indexOf(team);
        if (idx > -1) {
          $rootScope.selection.splice(idx, 1);
        } else {
          $rootScope.selection.push(team);
        }
      };
    })

  .run(function ($rootScope) {
    $rootScope.selection = ["Helpdesk"];
  });
