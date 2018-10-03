
window.ChaiBioTech.ngApp.directive('fixedHeader', fixedHeader);

fixedHeader.$inject = ['$timeout', '$window'];

function fixedHeader($timeout, $window) {
    return {
        restrict: 'A',
        link: link
    };

    function link($scope, $elem, $attrs, $ctrl) {
        var elem = $elem[0];

        // wait for data to load and then transform the table
        $scope.$watch(tableDataLoaded, function(isTableDataLoaded) {
            if (isTableDataLoaded) {
                transformTable();
                $timeout(function(){
                    var tbody = elem.querySelector('tbody');
                    var isScrollExist = tbody.scrollHeight - tbody.offsetHeight;
                    if (isScrollExist > 0) {
                        angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'scroll');
                    } else {
                        angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'auto');
                    }                    
                });
            }
        });

        $scope.$watch(tableScrollRender, function(isTableScrollRender) {            
            if (isTableScrollRender) {
                var tbody = elem.querySelector('tbody');
                var isScrollExist = tbody.scrollHeight - tbody.offsetHeight;
                if (isScrollExist > 0) {
                    angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'scroll');
                } else {
                    angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'auto');
                }
            }
        });

        angular.element($window).on('resize', transformTableOnResize);

        function tableScrollRender() {
            var tbody = elem.querySelector('tbody');
            return tbody.offsetHeight > 0 ? true :  false;
        }

        function tableDataLoaded() {
            // first cell in the tbody exists when data is loaded but doesn't have a width
            // until after the table is transformed
            var firstCell = elem.querySelector('tbody tr:first-child td:first-child');
            return firstCell && !firstCell.style.width;
        }

        function transformTableOnResize(){
            // reset display styles so column widths are correct when measured below
            angular.element(elem.querySelectorAll('thead, tbody, tfoot')).css('display', '');
            $timeout(function () {
                // set widths of columns
                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {

                    var tdElems = elem.querySelector('tbody tr:first-child td:nth-child(' + (i + 1) + ')');
                    var tfElems = elem.querySelector('tfoot tr:first-child td:nth-child(' + (i + 1) + ')');

                    var columnWidth = tdElems ? tdElems.offsetWidth : thElem.offsetWidth;
                    if (tdElems) {
                        tdElems.style.width = columnWidth + 'px';
                    }
                    if (thElem) {
                        thElem.style.width = columnWidth + 'px';
                    }
                    if (tfElems) {
                        tfElems.style.width = columnWidth + 'px';
                    }
                });

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'auto');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'overflow-y': 'auto'
                });
            });

        }

        function transformTable() {
            // reset display styles so column widths are correct when measured below
            angular.element(elem.querySelectorAll('thead, tbody, tfoot')).css('display', '');

            // wrap in $timeout to give table a chance to finish rendering
            $timeout(function () {
                // set widths of columns
                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {

                    var tdElems = elem.querySelector('tbody tr:first-child td:nth-child(' + (i + 1) + ')');
                    var tfElems = elem.querySelector('tfoot tr:first-child td:nth-child(' + (i + 1) + ')');

                    var columnWidth = tdElems ? tdElems.offsetWidth : thElem.offsetWidth;
                    if (tdElems) {
                        tdElems.style.width = columnWidth + 'px';
                    }
                    if (thElem) {
                        thElem.style.width = columnWidth + 'px';
                    }
                    if (tfElems) {
                        tfElems.style.width = columnWidth + 'px';
                    }
                });

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', 'auto');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'overflow-y': 'auto'
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = (lastColumn.offsetWidth + 7) + 'px';

            });
        }
    }
}