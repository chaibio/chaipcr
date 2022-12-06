App.directive 'aspectRatio', [
  'WindowWrapper'
  '$timeout'
  '$rootScope'
  '$window'
  (WindowWrapper, $timeout, $rootScope, $window) ->

    restrict: 'AE',
    scope:
      offsetX: '=?'
      offsetY: '=?'
      force: '=?'
      doc: '=?'
      minWidth: '=?'
      minHeight: '=?'
      maxWidth: '=?'
      maxHeight: '=?'
      offsetTop: '=?'
    link: ($scope, elem) ->

      elem.addClass 'aspect-Ratio'      

      getWidth = ->

        # console.log('parent_getWidth')
        # console.log(elem.parent().width())
        width = elem.parent().width() - $scope.offsetX
        if width > $scope.maxWidth
          width = $scope.maxWidth
        else if width < $scope.minWidth
          width = $scope.minWidth
        # console.log('resizeAspectRatio_getWidth')
        # console.log(width)
        width

      getHeight = -> 
        # console.log('parent_getHeight')
        # console.log(elem.parent().parent().parent().height())
        height = elem.parent().parent().parent().height() - ($scope.offsetY)
        if height > $scope.maxHeight
          height = $scope.maxHeight
        else if height < $scope.minHeight
          height = $scope.minHeight
        # console.log('resizeAspectRatio_getHeight')
        # console.log(height)
        # if height > elem.parent().height()  then height = elem.parent().height()
        height

      resizeDesktopAspectRatio = -> 
        width = getWidth()
        height = getHeight()

        if width > $scope.maxWidth and height > $scope.maxHeight
          width = $scope.maxWidth
          height = $scope.maxHeight
        else if width < $scope.minWidth and height < $scope.minHeight
          width = $scope.minWidth
          height = $scope.minHeight
        else           
          if height <= $scope.minHeight            
            width = Math.min(width / 1.7, height) * 1.7
            height = Math.min(width / 1.7, height) - 20
          else
            width = Math.max(width / 1.7, height) * 1.7
            height = Math.max(width / 1.7, height)

        elem.css('min-Width': width)
        elem.css('width': width)
        elem.css('min-height': height)
        elem.css('height': height)    
        angular.element('.choose-chart').removeClass('small')
        # angular.element('.chart-screen-wapper').css('min-width': 1368)
        angular.element('.chart-screen-wapper').css('min-width': 0)

        elem.parent().children().last().get(0).style.height = height + "px"
        angular.element(elem.parent().children().last().get(0)).children().last().get(0).style.height = height - $scope.offsetTop + "px"

        element = elem.parent().children().last().get(0)
        offsetWidth = element.getElementsByClassName('target-box')[0].offsetWidth if element.getElementsByClassName('target-box')[0]
        offsetHeight = element.getElementsByClassName('target-box')[0].offsetHeight if element.getElementsByClassName('target-box')[0]
        scrollHeight = element.getElementsByClassName('target-box')[0].scrollHeight if element.getElementsByClassName('target-box')[0]
        if offsetHeight != scrollHeight and offsetWidth == 150
          element.getElementsByClassName('target-box')[0].style.padding = "5px 20px 5px 10px"
        else if offsetHeight == scrollHeight
          element.getElementsByClassName('target-box')[0].style.padding = "5px 10px"
        return

      resizeTabletAspectRatio = ->
        innerHeight = window.innerHeight
        innerWidth = window.innerWidth


        minHeight = if innerWidth > 1024 then 780 else 640
        maxHeight = if innerWidth > 768 then 1024 else 720
        paddingHeight = 60

        if innerWidth > 1112
          minHeight = 960
          maxHeight = 1024
          wellTableHeight = 175
        else if innerWidth > 1024
          minHeight = 720
          maxHeight = 1024
          wellTableHeight = 130
          paddingHeight = 40
        else if innerWidth > 992
          minHeight = 640
          maxHeight = 1024
          wellTableHeight = 110
          paddingHeight = 40
        else
          minHeight = 840
          maxHeight = 1024
          wellTableHeight = 110
          paddingHeight = 40
       
        height = Math.min(Math.max(innerHeight, minHeight), maxHeight) - 100 - 100 - 60  - paddingHeight - wellTableHeight
        width = height * 1.7

        elem.css('min-Width': width)
        elem.css('width': width)
        elem.css('min-height': height)
        elem.css('height': height)

        if wellTableHeight == 175
          angular.element('.choose-chart').removeClass('small')
        else
          angular.element('.choose-chart').addClass('small')

        # angular.element('.chart-screen-wapper').css('min-width': width + 40 + 620)
        angular.element('.chart-screen-wapper').css('min-width': 0)

        return

      resizeAspectRatio = -> 
        innerWidth = window.innerWidth
        if innerWidth > 1366
          resizeDesktopAspectRatio()
        else
          resizeTabletAspectRatio()



      resizeTimeout = null
      
      # $scope.$watch (->
      #   angular.element(elem).parent().parent().parent().height()        
      # ), (isResize) ->
      #   if isResize
      #     runAspectRatio()
      #     $timeout ->
      #       $rootScope.$broadcast 'event:resize-draw-chart'
      #     , 100

      $scope.$on 'window:resize', ->
        # console.log('window:resize')
        runAspectRatio()
        $timeout ->
          $rootScope.$broadcast 'event:resize-draw-chart'
        , 100

      $rootScope.$on 'sidemenu:toggle', ->
        runAspectRatio()
        $timeout ->
          $rootScope.$broadcast 'event:resize-draw-chart'
        , 300

      runAspectRatio = (send_event = false) ->
        resizeAspectRatio()
        if resizeTimeout
          $timeout.cancel(resizeTimeout)
        resizeTimeout = $timeout ->
          elem.css(overflow: '', width: '', 'min-width': '', height: '', 'min-height': '')
          resizeAspectRatio()
          resizeTimeout = null
          if send_event
            $rootScope.$broadcast 'event:resize-aspect-ratio'
        , 500

      # console.log('aspectRatio: init')      
      
      $scope.$on 'event:start-resize-aspect-ratio', ->
        runAspectRatio(true)

      $timeout ->
        runAspectRatio(true)
      , 1000       
]