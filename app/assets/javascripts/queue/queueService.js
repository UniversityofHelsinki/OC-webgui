angular.module('ocWebGui.queue.service', ['ngResource'])
  .factory('Queue', function ($resource) {
    function getLanguage(service_id) {
      switch (service_id) {
        case 135:
        case 137:
        case 136:
          return 'Fin';
        case 125:
        case 131:
        case 121:
          return 'Eng';
        case 133:
          return 'Swe';
        default:
          return 'Unknown';
      }
    }
    return $resource('queue.json', {}, {
      query: {
        method: 'get',
        isArray: true,
        transformResponse: function (data) {
          var queue = angular.fromJson(data);
          return queue.map(function (queuer) {
            queuer.language = getLanguage(queuer.service_id);
            queuer.created_at = new Date(queuer.created_at);
            return queuer;
          });
        }
      }
    });
  });
