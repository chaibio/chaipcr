App.service 'ModalError', [
  '$modal'
  '$rootScope'
  ($modal, $rootScope) ->

    self = @
    $scope = $rootScope.$new()

    self.open = (err) ->
      $scope.title = err.title || 'ERROR'
      $scope.message = err.message
      $scope.date = err.date

      $modal.open
        templateUrl: 'app/views/directives/error-modal.html'
        scope: $scope
        windowClass: 'modal-error-window'

    return self

]