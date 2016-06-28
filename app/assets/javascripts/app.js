angular.module('ocWebGui', ['templates', 'ocWebGui.home', 'ocWebGui.screen',
  'ocWebGui.queue', 'ocWebGui.filterpanel', 'ocWebGui.stats', 'ocWebGui.login'])
  .run(function ($rootScope, $state, User) {
    $rootScope.returnToState = 'home';
    $rootScope.returnToParams = {};
    $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
      if (toState.name === 'stats' && !User.isAuthenticated()) {
        $rootScope.returnToState = toState;
        $rootScope.returnToParams = toParams;
        event.preventDefault();
        $state.go('login');
      }
    });
  });
