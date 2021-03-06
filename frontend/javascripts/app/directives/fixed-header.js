
window.ChaiBioTech.ngApp.directive('fixedHeader', fixedHeader);

fixedHeader.$inject = ['$timeout', '$window', '$rootScope'];

function fixedHeader($timeout, $window, $rootScope) {
    return {
        restrict: 'A',
        link: link
    };

    function link($scope, $elem, $attrs, $ctrl) {
        var elem = $elem[0];
        var timeout = null;

        // wait for data to load and then transform the table
        $scope.$watch(tableDataLoaded, function(isTableDataLoaded) {
            if (isTableDataLoaded) {
                transformTable();
            }
        });

        $scope.$watch(tableScrollRender, function(isTableScrollRender) {            
            if(isTableScrollRender){
                transformTableOnResize();
            }
        });

        angular.element($window).on('resize', onResizeWindow);

        $rootScope.$on('sidemenu:toggle', function(){
            if (timeout) {
              $timeout.cancel(timeout);
              timeout = null;
            }
            timeout = $timeout(function() {
              onResizeWindow();
              timeout = null;
            }, 300);
        });

        function tableScrollRender() {
            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = tbodyElems.offsetWidth - tbodyElems.scrollWidth;
            var overflow_style = (scrollWidth) ? 'scroll' : 'auto';
            var head_flow = angular.element(elem.querySelectorAll('thead')).css('overflow-y');

            if(overflow_style != head_flow){
                transformTableOnResize();
            }
            return angular.element(elem).parent().height();
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
            var trHeight = (elem.querySelector('tbody tr:first-child td:last-child')) ? elem.querySelector('tbody tr:first-child td:last-child').offsetHeight - 1 : 0;
            var trCount = (elem.querySelectorAll('tbody tr').length) ? elem.querySelectorAll('tbody tr').length : 0;

            var parentHeight = angular.element(elem).parent()[0].offsetHeight;
            var tableHeight = trHeight * (trCount + 2);
            var tbodyHeight = (parentHeight > tableHeight + 100) ? tableHeight - 50 : parentHeight - 150;

            $timeout(function () {
                // set widths of columns

                // angular.element(elem).css('height', tableHeight + 'px');
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

                var overflow_style = (isScrollExist && scrollWidth && trCount) ? 'scroll' : 'auto';

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', overflow_style);
                angular.element(elem.querySelectorAll('thead, tfoot')).css('border-bottom', '1px solid #bbb');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    // 'max-height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'height' : tbodyHeight + 'px',
                    'overflow-y': 'auto'
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';

                lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                if(lastColumn){
                    lastColumn.style.width = lastColumnWidth + 'px';
                }

            });

        }

        function transformTable() {
            // reset display styles so column widths are correct when measured below
            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = tbodyElems.offsetWidth - tbodyElems.scrollWidth;
            var lastColumnWidth = elem.querySelector('thead tr:first-child th:last-child').attributes.width.value;
            lastColumnWidth = lastColumnWidth.replace('px', '');
            var isScrollExist = tbodyElems.scrollHeight - tbodyElems.offsetHeight;

            var trHeight = (elem.querySelector('tbody tr:first-child td:last-child')) ? elem.querySelector('tbody tr:first-child td:last-child').offsetHeight - 1 : 0;
            var trCount = (elem.querySelectorAll('tbody tr').length) ? elem.querySelectorAll('tbody tr').length : 0;

            var parentHeight = angular.element(elem).parent()[0].offsetHeight;
            var tableHeight = trHeight * (trCount + 2);
            var tbodyHeight = (parentHeight > tableHeight + 100) ? tableHeight - 50 : parentHeight - 150;

            // wrap in $timeout to give table a chance to finish rendering
            $timeout(function () {
                // set widths of columns

                // angular.element(elem).css('height', tableHeight + 'px');
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

                var overflow_style = (isScrollExist && scrollWidth && trCount) ? 'scroll' : 'auto';

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', overflow_style);
                angular.element(elem.querySelectorAll('thead, tfoot')).css('border-bottom', '1px solid #bbb');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    // 'max-height': $attrs.tableHeight || 'calc(100% - 50px)',
                    'height' : tbodyHeight + 'px',
                    'overflow-y': 'auto'
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';

                lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                if(lastColumn){
                    lastColumn.style.width = lastColumnWidth + 'px';
                }
            });
        }
    }
}