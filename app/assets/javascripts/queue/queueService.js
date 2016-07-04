angular.module('ocWebGui.queue.service', ['ngResource'])
  .factory('Queue', function ($resource) {
    function getLanguage(line) {
      switch (line) {
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
            queuer.language = getLanguage(queuer.line);
            queuer.time_in_queue = Math.round(new Date().getTime() / 1000) - Math.round(new Date(queuer.created_at).getTime() / 1000)
            return queuer;
          });
        }
      }
    });
  });
