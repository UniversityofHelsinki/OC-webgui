angular.module('ocWebGui.shared.trimName.service', [])
  .factory('TrimName', function () {
    return { 
      trim: function(firstName, lastName) {
        return firstName + ' ' + lastName.charAt(0); 
      }
    }
  });
