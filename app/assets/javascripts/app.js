angular.module('ocWebGui', ['ui.router', 'templates', 'ocWebGui.home', 'ocWebGui.screens.status',
    'ocWebGui.screens.queue', 'ocWebGui.stats', 'ocWebGui.login', 'ocWebGui.navbar',
    'ocWebGui.personal', 'ocWebGui.shared.color', 'ocWebGui.shared.settings', 'ocWebGui.settings',
    '720kb.datepicker', 'ngSanitize', 'ngCsv', 'ocWebGui.shared.user.middleware'])
  .config(function ($stateProvider) {
    $stateProvider
      .state('app', {
        abstract: true,
        template: '<ui-view name="nav"></ui-view><ui-view name="content"></ui-view>',
        resolve: {
          preloadUser: function (UserMiddleware) {
            return UserMiddleware.preload();
          }
        }
      });
  })
  .run(function ($rootScope, $state, User, $interval, Settings) {
    var $body = $(document.body);
    var $colorMenu = $('.legend');
    var $navbar = $('.navbar');
    var $queue = $('.answer');
    var $personal = $('.personal-statistics');
    var mouseHideTimeout;

    Settings.getColor('font').then(function (color) {
      $body.css('color', color);
      $colorMenu.css('color', color);
      $colorMenu.css('border-bottom-color', color);

      $queue.css('border-bottom-color', color);
      $personal.css('color', color);
      $personal.css('border-bottom-color', color);
    });

    $rootScope.$on('settings:colors:update', function () {
      Settings.getColor('font').then(function (color) {
        $body.css('color', color);
        $colorMenu.css('color', color);
        $colorMenu.css('border-bottom-color', color);

        $queue.css('border-bottom-color', color);
        $personal.css('color', color);
      });
    });

    function createHideMouseTimeout() {
      return $interval(function () {
        $body.addClass('hide-mouse');
      }, 2000, 1);
    }

    function activateNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);
      mouseHideTimeout = createHideMouseTimeout();
      $body.addClass('body-screen');

      $body.on('mousemove', function () {
        $body.removeClass('hide-mouse');
        $interval.cancel(mouseHideTimeout);
        mouseHideTimeout = createHideMouseTimeout();
      });
    }

    function disableNavbarOverlay() {
      $interval.cancel(mouseHideTimeout);

      $body.removeClass('hide-mouse').off('mousemove');
      $body.removeClass('body-screen');
    }

    $rootScope.returnToState = 'app.home';
    $rootScope.returnToParams = {};

    $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
      if (toState.navbarOverlay === true) {
        activateNavbarOverlay();
      } else {
        disableNavbarOverlay();
      }
      if (toState.name !== 'app.login') {
        $rootScope.returnToState = toState;
        $rootScope.returnToParams = toParams;
      }
    });
  });

function colorChange(Settings) {
  // never used?
}
