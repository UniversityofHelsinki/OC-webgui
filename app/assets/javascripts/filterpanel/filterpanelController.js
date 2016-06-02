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
      // kaikki vaihtoehdot
      $scope.teams = ["Hakijapalvelut", "Helpdesk", "Opiskelijaneuvonta", "OrangeContact 1", "Puhelinvaihde", "Uaf"];
      $scope.states = ["BACKOFFICE", "<TELJENTÄ>", "Sisäänkirjaus", "TAUKO", "12648", "PUHELU (Sisään)", "PUHELU (Ulos)"];

      $scope.toggleSelection = function toggleSelection(team) {
        var idx = $rootScope.selection.indexOf(team);
        if (idx > -1) {
          $rootScope.selection.splice(idx, 1);
        } else {
          $rootScope.selection.push(team);
        }
      };

      $scope.toggleSelection2 = function toggleSelection2(state) {
        var idx = $rootScope.selectedStates.indexOf(state);
        if (idx > -1) {
          $rootScope.selectedStates.splice(idx, 1);
        } else {
          $rootScope.selectedStates.push(state);
        }
      };
    })

  .run(function ($rootScope) {
    // oletusvalinnat
    $rootScope.selection = ["Helpdesk"];
    $rootScope.selectedStates = ["Sisäänkirjaus", "TAUKO", "PUHELU (Sisään)", "PUHELU (Ulos)"];
  });
