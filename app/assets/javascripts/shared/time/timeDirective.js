angular.module('ocWebGui.shared.time', [])
    .directive('ocTime', function($interval) {
        return {
            restrict: 'E',
            scope: {
                seconds: '='
            },
            link: function(scope, element) {
                function pad2(value) {
                    return (value < 10 ? '0' : '') + value;
                }

                function updateTime() {
                    var seconds = currentSeconds % 60;
                    var minutes = Math.floor(currentSeconds / 60);
                    element.text(pad2(minutes) + ':' + pad2(seconds));
                }

                scope.$watch('seconds', function(value) {
                    currentSeconds = value;
                    updateTime();
                });

                var timeoutId = $interval(function() {
                    currentSeconds++;
                    updateTime();
                }, 1000);

                element.on('$destroy', function() {
                    $interval.cancel(timeoutId);
                });

                var currentSeconds = scope.seconds;

                updateTime();
            }
        };
    });
