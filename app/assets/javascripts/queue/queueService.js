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
          return queue
              // Map calling lines by language
              .map(function (queuer) {
                queuer.language = getLanguage(queuer.line);
                queuer.created_at = new Date(queuer.created_at);
                return queuer;
              })
              // Filter out queuers mapped as Unknown
              // (Unknown = line belongs to another team, not Helpdesk.
              //  Filtering/getLanguage needs be based on team later, not hard coded.)
              .filter(function (queuer) {
                return queuer.language !== 'Unknown';
              });
        }
      }
    });
  });
