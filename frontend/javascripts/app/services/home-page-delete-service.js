window.ChaiBioTech.ngApp.service('HomePageDelete', [
  '$window',
  function($window) {
    this.activeDelete = false;
    this.activeDeleteElem = false;
    var _this = this;

    angular.element($window).click(function(evt) {
      if(_this.activeDelete && evt.target.className !== 'home-page-bin') {
        _this.disableActiveDelete();
        angular.element(_this.activeDeleteElem).parent()
          .removeClass('home-page-active-del-identifier');
      }
    });

    this.deactiveate = function(currentScope) {

      if(this.activeDelete) {
        if(currentScope.$id !== this.activeDelete.$id) {
          this.activeDelete.deleteClicked = false;
        } else if(currentScope.$id === this.activeDelete.$id) {
          this.activeDelete = false;
          this.activeDeleteElem = false;
        }
      }

    };

    this.disableActiveDelete = function() {
      this.activeDelete.deleteClicked = false;
    };
  }
]);
