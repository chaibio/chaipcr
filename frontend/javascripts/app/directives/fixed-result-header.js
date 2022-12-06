
window.ChaiBioTech.ngApp.directive('fixedResultHeader', fixedResultHeader);

fixedResultHeader.$inject = ['$timeout', '$window', '$rootScope'];

function fixedResultHeader($timeout, $window, $rootScope) {
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

        $rootScope.$on('event:switch-view-mode', function(){
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
            var selected_count = elem.querySelectorAll('tbody tr.selected') ? elem.querySelectorAll('tbody tr.selected').length : 0;
            var omitted_count = elem.querySelectorAll('tbody tr.omitted') ? elem.querySelectorAll('tbody tr.omitted').length : 0;
            return selected_count + omitted_count;
        }

        function parentWidthChanged(){
            return angular.element(elem).parent()[0].offsetWidth;
        }

        function tableColumnChanged(){
            return elem.querySelectorAll('thead tr th').length;
        }

        function onResizeWindow(){
            transformTableOnResize();
        }

        function transformTableOnResize(){
            // reset display styles so column widths are correct when measured below
            var tableOffsetHeight = elem.attributes.offset ? parseInt(elem.attributes.offset.value) : 0;
            var tableMinWidth = elem.attributes['min-width'] ? parseInt(elem.attributes['min-width'].value) : 0;
            $(elem).css({minWidth: '100%'});
            $(elem).css({width: '100%'});
            var parentWidth = angular.element(elem).parent()[0].offsetWidth;

            var tbodyElems = elem.querySelector('tbody');
            var scrollWidth = Math.abs(tbodyElems.offsetWidth - tbodyElems.scrollWidth);
            var lastColumnWidth = elem.querySelector('thead tr:first-child th:last-child').attributes.width.value;
            lastColumnWidth = lastColumnWidth.replace('px', '');
            var isScrollExist = tbodyElems.scrollHeight - tbodyElems.offsetHeight;

            var trHeight = (elem.querySelector('tbody tr.selected td:last-child')) ? elem.querySelector('tbody tr.selected td:last-child').offsetHeight : 0;
            trHeight = (trHeight == 0 && elem.querySelector('tbody tr.omitted td:last-child')) ? elem.querySelector('tbody tr.omitted td:last-child').offsetHeight : trHeight;

            var thHeight = (elem.querySelector('thead tr:first-child th:last-child')) ? elem.querySelector('thead tr:first-child th:last-child').offsetHeight : 0;
            var trCount = (elem.querySelectorAll('tbody tr').length) ? elem.querySelectorAll('tbody tr').length : 0;

            var parentHeight = angular.element(elem).parent()[0].offsetHeight - tableOffsetHeight;
            var scrollHeight = Math.abs(angular.element(elem).parent()[0].offsetHeight - angular.element(elem).parent()[0].scrollHeight);

            var tableHeight = trHeight * trCount + thHeight;
            var tbodyHeight = (parentHeight > tableHeight + scrollHeight) ? tableHeight - thHeight : parentHeight - thHeight;

            $timeout(function () {
                // set widths of columns
                var fixedWidth = 0;
                var parentBorder = 3;
                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {
                    if(thElem.attributes.width.value.indexOf('px') != -1){
                        fixedWidth += parseInt(thElem.attributes.width.value.replace('px', ''));
                    }
                });

                var validWidth = (tableMinWidth > parentWidth ? tableMinWidth : parentWidth - 3) - scrollWidth - fixedWidth;
                var innerWidth = window.innerWidth;

                angular.forEach(elem.querySelectorAll('tr:first-child th'), function (thElem, i) {
                    var tdElems = elem.querySelectorAll('tbody tr td:nth-child(' + (i + 1) + ')');
                    var tfElems = elem.querySelector('tfoot tr td:nth-child(' + (i + 1) + ')');
                    var widthPercent = thElem.attributes.width.value.replace('%', '');

                    angular.forEach(tdElems, function(tdElem, i){
                        if(thElem.attributes.width.value.indexOf('%') != -1){
                            if(innerWidth > 1368){
                                tdElem.style.width = (widthPercent * validWidth / 100) + 'px';
                            } else {
                                if(widthPercent == '100'){
                                    tdElem.style.width = '120px';
                                } else {
                                    tdElem.style.width = (widthPercent * validWidth / 100) + 'px';
                                }
                            }
                            // tdElem.style.width = widthPercent + '%';
                        } else {
                            tdElem.style.width = thElem.attributes.width.value;
                        }
                    });

                    if (thElem) {
                        if(thElem.attributes.width.value.indexOf('%') != -1){
                            if(innerWidth > 1368){
                                thElem.style.width = (widthPercent * validWidth / 100) + 'px';
                            } else {
                                if(widthPercent == '100'){
                                    thElem.style.width = '120px';
                                } else {
                                    thElem.style.width = (widthPercent * validWidth / 100) + 'px';
                                }
                            }
                        } else {
                            thElem.style.width = thElem.attributes.width.value;
                        }
                    }
                    if (tfElems) {
                        if(thElem.attributes.width.value.indexOf('%') != -1){
                            // tfElems.style.width = (widthPercent * validWidth / 100) + 'px';
                        } else {
                            tfElems.style.width = thElem.attributes.width.value;
                        }
                    }
                });

                var overflow_style = (isScrollExist && scrollWidth && trCount) ? 'scroll' : 'auto';

                // set css styles on thead and tbody
                angular.element(elem.querySelectorAll('thead, tfoot')).css('display', 'block');
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-y', overflow_style);
                angular.element(elem.querySelectorAll('thead, tfoot')).css('overflow-x', 'hidden');

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'height' : tbodyHeight + 'px',
                    'overflow-y': 'auto',                    
                });

                var lastColumn = elem.querySelector('thead tr:first-child th:last-child');
                lastColumn.style.width = lastColumnWidth + 'px';

                lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                if(lastColumn){
                    lastColumn.style.width = lastColumnWidth + 'px';
                }
            }, 100);

        }
    }
}