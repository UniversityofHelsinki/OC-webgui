angular.module('ocWebGui.personal', ['ui.router'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('personal', {
        url: '/personal',
        templateUrl: 'personal/_personal.html',
        controller: 'PersonalController',
        controllerAs: 'personal'
      });
  })
  .controller('PersonalController', function () {
    var vm = this;
  });
