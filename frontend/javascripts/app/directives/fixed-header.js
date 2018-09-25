
window.ChaiBioTech.ngApp.directive('fixedHeader', fixedHeader);

fixedHeader.$inject = ['$timeout'];

function fixedHeader($timeout) {
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

        function tableDataLoaded() {
            // first cell in the tbody exists when data is loaded but doesn't have a width
            // until after the table is transformed
            var firstCell = elem.querySelector('tbody tr:first-child td:first-child');
            return firstCell && !firstCell.style.width;
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

                angular.element(elem.querySelectorAll('tbody')).css({
                    'display': 'block',
                    'height': $attrs.tableHeight || 'inherit',
                    'overflow': 'auto'
                });

                // reduce width of last column by width of scrollbar
                var tbody = elem.querySelector('tbody');
                var scrollBarWidth = tbody.offsetWidth - tbody.clientWidth;
                if (scrollBarWidth > 0) {
                    // for some reason trimming the width by 2px lines everything up better
                    scrollBarWidth -= 2;
                    var lastColumn = elem.querySelector('tbody tr:first-child td:last-child');
                    lastColumn.style.width = (lastColumn.offsetWidth - scrollBarWidth) + 'px';
                }
            });
        }
    }
}