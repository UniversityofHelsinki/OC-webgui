angular.module('ocWebGui.shared.time.service', [])
  .factory('CustomDate', function () {
    return {
      getDate: function () {
        return new Date();
      }
    };
  });
