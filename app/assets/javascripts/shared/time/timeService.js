angular.module('ocWebGui.shared.time.service', ['ngResource'])
  .factory('CustomDate', function () {
    return {
      getDate: function () {
        return new Date();
      }
    };
  });
