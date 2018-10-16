
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
            }
        });

        $scope.$watch(tableScrollRender, function(isTableScrollRender) {            
            if (isTableScrollRender) {
                transformTableOnResize();
            }
        });

        angular.element($window).on('resize', onResizeWindow);

        function tableScrollRender() {
            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = tbodyElems.scrollWidth - tbodyElems.scrollWidth;
            return tbodyElems.scrollHeight * tbodyElems.offsetHeight;
        }


        function tableDataLoaded() {
            // first cell in the tbody exists when data is loaded but doesn't have a width
            // until after the table is transformed
            var firstCell = elem.querySelector('tbody tr:first-child td:first-child');
            return firstCell && !firstCell.style.width;
        }

        function onResizeWindow(){
            transformTableOnResize();
        }

        function transformTableOnResize(){
            // reset display styles so column widths are correct when measured below

            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = tbodyElems.offsetWidth - tbodyElems.scrollWidth;
            var lastColumnWidth = elem.querySelector('thead tr:first-child th:last-child').attributes.width.value;
            lastColumnWidth = lastColumnWidth.replace('px', '');
            var isScrollExist = tbodyElems.scrollHeight - tbodyElems.offsetHeight;
            var trHeight = elem.querySelector('tbody tr:first-child td:last-child').offsetHeight - 1;
            var trCount = (elem.querySelectorAll('tbody tr').length) ? elem.querySelectorAll('tbody tr').length : 0;

            var tableHeight = trHeight * (trCount + 2);

            $timeout(function () {
                // set widths of columns
                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {
                    var tdElems = elem.querySelector('tbody tr:first-child td:nth-child(' + (i + 1) + ')');
                    var tfElems = elem.querySelector('tfoot tr:first-child td:nth-child(' + (i + 1) + ')');
                    var validWidth = tbodyElems.scrollWidth - lastColumnWidth;
                    var widthPercent = thElem.attributes.width.value.replace('%', '');

                    if (tdElems) {
                        tdElems.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                    if (thElem) {
                        thElem.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                    if (tfElems) {
                        tfElems.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                });

                var overflow_style = (isScrollExist) ? 'scroll' : 'auto';

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', overflow_style);
                angular.element(elem.querySelectorAll('thead, tfoot')).css('border-bottom', '1px solid #bbb');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'max-height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'overflow-y': 'auto'
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';

                lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';
                angular.element(elem).css('height', tableHeight + 'px');
            });

        }

        function transformTable() {
            // reset display styles so column widths are correct when measured below
            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = tbodyElems.offsetWidth - tbodyElems.scrollWidth;
            var lastColumnWidth = elem.querySelector('thead tr:first-child th:last-child').attributes.width.value;
            lastColumnWidth = lastColumnWidth.replace('px', '');
            var isScrollExist = tbodyElems.scrollHeight - tbodyElems.offsetHeight;

            var trHeight = elem.querySelector('tbody tr:first-child td:last-child').offsetHeight - 1;
            var trCount = (elem.querySelectorAll('tbody tr').length) ? elem.querySelectorAll('tbody tr').length : 0;

            var tableHeight = trHeight * (trCount + 2);

            // wrap in $timeout to give table a chance to finish rendering
            $timeout(function () {
                // set widths of columns
                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {
                    var tdElems = elem.querySelector('tbody tr:first-child td:nth-child(' + (i + 1) + ')');
                    var tfElems = elem.querySelector('tfoot tr:first-child td:nth-child(' + (i + 1) + ')');
                    var validWidth = tbodyElems.scrollWidth - lastColumnWidth;
                    var widthPercent = thElem.attributes.width.value.replace('%', '');

                    if (tdElems) {
                        tdElems.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                    if (thElem) {
                        thElem.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                    if (tfElems) {
                        tfElems.style.width = (widthPercent * validWidth / 100) + 'px';
                    }
                });

                var overflow_style = (isScrollExist) ? 'scroll' : 'auto';

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', overflow_style);
                angular.element(elem.querySelectorAll('thead, tfoot')).css('border-bottom', '1px solid #bbb');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'max-height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'overflow-y': 'auto'
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';

                lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';
                angular.element(elem).css('height', tableHeight + 'px');
            });
        }
    }
}