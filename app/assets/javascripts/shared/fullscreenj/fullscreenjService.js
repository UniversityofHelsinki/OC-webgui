angular.module('ocWebGui.shared.fullscreen', ['FBAngular'])
  .factory('MyFullscreen', function (Fullscreen) {
    return {
      goFullScreen: function () {
        if (Fullscreen.isEnabled()) {
          Fullscreen.cancel();
        } else {
          Fullscreen.all();
        }
      }
    };
  });
