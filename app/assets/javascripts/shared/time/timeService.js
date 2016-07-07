angular.module('ocWebGui.shared.time.service', ['ngResource'])
  .factory('CustomDate', function ($resource) {
    return {
      getDate: function () {
        return new Date();
      }
    };
  });
