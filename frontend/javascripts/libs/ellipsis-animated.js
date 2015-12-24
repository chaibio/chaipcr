angular.module('ellipsisAnimated', [])

.directive('ellipsisAnimated', function () { 

    return {

        restrict: "EAC",

        template:
            "<span class='ellipsis_animated-inner'>" +
                "<span>.</span>" +
                "<span>.</span>" +
                "<span>.</span>" +
            "</span>",

    };

})

;
