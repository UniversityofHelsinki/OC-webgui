angular.module('ocWebGui.shared.confirmClick', [])
  .directive('ocConfirmClick', [
        function(){
            return {
                link: function (scope, element, attr) {
                    var msg = attr.ocConfirmClick || "Oletko varma?";
                    var clickAction = attr.confirmedClick;
                    element.bind('click',function (event) {
                        if ( window.confirm(msg) ) {
                            scope.$eval(clickAction)
                        }
                    });
                }
            };
    }])
