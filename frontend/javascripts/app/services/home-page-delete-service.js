window.ChaiBioTech.ngApp.service('HomePageDelete', [

  function() {
    this.activeDelete = null;
    this.activeDeleteElem = null;

    this.deactiveate = function(currentScope) {

      if(this.activeDelete) {
        if(currentScope.$id !== this.activeDelete.$id) {
          this.activeDelete.deleteClicked = false;
        } else if(currentScope.$id === this.activeDelete.$id) {
          this.activeDelete = null;
          this.activeDeleteElem = null;
        }
      }

    };
  }
]);
