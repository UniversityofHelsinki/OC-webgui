angular.module('ocWebGui.colormanagement', ['ui.router', 'ocWebGui.shared.time'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('colormanagement', {
        url: '/colors',
        templateUrl: 'color_management/_colormanagement.html',
        controller: 'colorManagementController',
        controllerAs: 'colormanagement',
        navbarOverlay: true
      });
  })
  .controller('colorManagementController', function () {
    
  });