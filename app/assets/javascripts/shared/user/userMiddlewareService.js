angular.module('ocWebGui.shared.user.middleware', ['ui.router', 'ocWebGui.shared.user'])
  .factory('UserMiddleware', function ($q, $timeout, $state, User) {
    return {
      preload: function () {
        return User.fetchUser();
      },
      requireAdmin: function () {
        var deferred = $q.defer();
        if (User.isAdmin()) {
          deferred.resolve();
        } else {
          $timeout(function () {
            $state.go('app.login');
          });
          deferred.reject();
        }
        return deferred.promise;
      }
    };
  });
