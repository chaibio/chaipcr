(function() {
  'use strict'

  describe('Protocol Screen Responsive Bottom Half Directive', function() {

    var template = '<div protocol-screen-center-bottom-half>\
      <div action="previous"></div>\
      <div class="middle-ground">\
          <div class="first-data-row">\
            <div class="general-info-container">\
              <div class="bottom-gather-data"></div>\
            </div>\
            <div class="summary-mode"></div>\
          </div>\
          <div class="data-boxes-container">\
            <div class="data-box-container-summary">\
              <div class="data-box-container-summary-scroll">\
                <div class="data-boxes temperature-change">\
                  <div class="name-board"></div>\
                  <div class="bottom-common-item"></div>\
                </div>\
                <div class="data-boxes auto-delta">\
                  <div class="name-board"></div>\
                  <div class="bottom-common-item"></div>\
                </div>\
                <div class="data-boxes exp-overview">\
                  <div class="name-board"></div>\
                  <div class="bottom-common-item"></div>\
                </div>\
                <div class="data-boxes exp-metadata">\
                  <div class="name-board"></div>\
                  <div class="bottom-common-item"></div>\
                </div>\
              </div>\
              <div class="data-boxes edit-stage-step">\
                <button class="big_button"></button>\
                <button class="big_button_disabled"></button>\
                <button class="small_button"></button>\
                <button class="small_button_disabled"></button>\
              </div>\
            </div>\
        </div>\
        <div class="lol-pop">\
          \
        </div>\
    </div>\
    <div action="next"></div>\
  </div>'

    describe('Resize handler', function() {

      beforeEach(function() {
        // turn off previous window resize handlers
        $(window).off('resize')

        module('ChaiBioTech', function($provide) {
          mockCommonServices($provide)
        })

        inject(function($injector) {
          this.$compile = $injector.get('$compile')
          this.$timeout = $injector.get('$timeout')
          this.$window = $injector.get('$window')
          this.WindowWrapper = $injector.get('WindowWrapper')
          this.$rootScope = $injector.get('$rootScope')
          this.scope = this.$rootScope.$new()
        })

        spyOn(this.$window.$.fn, 'resize')

        var elem = angular.element(template)
        this.directive = this.$compile(elem)(this.scope)
        this.scope.$digest()
        this.$timeout.flush()

      })

      it('should add flag for protocol-screen-center-bottom-half resize handler', function() {
        expect(this.WindowWrapper.events.resize['protocol-screen-center-bottom-half']).toBe(true)
      })

      it('should add resize listener only once', function() {
        // create 2nd directive to trigger add listener
        var elem = angular.element(template)
        var scope = this.$rootScope.$new()
        var d2 = this.$compile(elem)(scope)
        scope.$digest()
        expect(this.$window.$.fn.resize).toHaveBeenCalledTimes(1)
      })

    })


    describe('Adjust method', function() {

      beforeEach(function() {
        // turn off previous window resize handlers
        $(window).off('resize')

        module('ChaiBioTech', function($provide) {
          mockCommonServices($provide)
        })

        inject(function($injector) {
          this.$compile = $injector.get('$compile')
          this.$timeout = $injector.get('$timeout')
          this.$window = $injector.get('$window')
          this.WindowWrapper = $injector.get('WindowWrapper')
          this.$rootScope = $injector.get('$rootScope')
          this.scope = this.$rootScope.$new()
        })

        var elem = angular.element(template)
        this.directive = this.$compile(elem)(this.scope)
        this.$timeout.flush()

        this.prev = this.directive.find('[action="previous"]')
        this.next = this.directive.find('[action="next"]')
        this.middleGround = this.directive.find('.middle-ground')
        this.generalInfo = this.directive.find('.general-info-container')
        this.bottomGatherData = this.directive.find('.bottom-gather-data')
        this.bottomGatherDataWidth = 243
        this.summaryMode = this.directive.find('.summary-mode')
        this.dataBoxesContainer = this.directive.find('.data-boxes-container')
        this.dataBoxesSummary = this.directive.find('.data-box-container-summary')
        this.dataBoxesSummaryScroll = this.directive.find('.data-box-container-summary-scroll')
        this.bottomCommonItem = this.directive.find('.bottom-common-item, .name-board')
        this.dataBoxes = this.dataBoxesSummaryScroll.find('.data-boxes')
        this.dataBoxesEdit = this.directive.find('.data-boxes.edit-stage-step')
        this.lolPopUp = this.directive.find('.lol-pop')

        this.padding = 50;
        this.numVisibleDataBoxes = 3;
        this.numPadding = this.numVisibleDataBoxes - 1;
        this.eachBoxesWidth = (this.middleGround.width() - (this.padding * this.numPadding)) / this.numVisibleDataBoxes;

      })

      it('should set width of the directive root elem', function() {
        expect(this.directive.css('width')).toEqual(this.WindowWrapper.width() + 'px')
      })

      it('should set width of .middle-ground', function() {
        expect(this.middleGround.css('width')).toEqual(this.WindowWrapper.width() - this.prev.width() - this.next.width() + 'px')
      })

      it('should set width of .general-info-container', function() {
        expect(this.middleGround.css('width')).toEqual(this.WindowWrapper.width() - this.prev.width() - this.next.width() + 'px')
      })

      it('should set width of .bottom-gather-data', function() {
        expect(this.bottomGatherData.css('left')).toEqual((this.middleGround.width() - this.bottomGatherDataWidth - 4) + 'px')
      })

      it('should set width of .summary-mode', function() {
        expect(this.summaryMode.css('left')).toEqual(this.middleGround.width() + 'px')
        expect(this.summaryMode.css('width')).toEqual(this.middleGround.width() + 'px')
      })

      it('should set width of .data-boxes-container', function() {
        expect(this.dataBoxesContainer.css('width')).toEqual(this.middleGround.width() + 'px')
      })

      it('should set width of .data-box-container-summary', function() {
        expect(this.dataBoxesSummary.css('width')).toEqual((this.eachBoxesWidth * (this.numVisibleDataBoxes - 1) + this.padding) + 'px')
      })

      it('should set width of .data-boxes', function() {
        for (var i = 0; i < this.dataBoxes.length; i++) {
          var box = this.dataBoxes[i];
          var left = i * (this.eachBoxesWidth + this.padding);
          expect($(box).width()).toEqual(this.eachBoxesWidth)
          expect($(box).css('left')).toEqual(left + 'px')
        }
      })

      it('should set width of .bottom-common-item', function() {
        for (var i = 0; i < this.bottomCommonItem.length; i++) {
          var item = this.bottomCommonItem[i];
          expect($(item).width()).toEqual(this.eachBoxesWidth)
        }
      })

      it('should set width of dataBoxesEdit', function() {
        expect(this.dataBoxesEdit.width()).toEqual(this.eachBoxesWidth)
        expect(this.dataBoxesEdit.css('left')).toEqual((this.eachBoxesWidth + this.padding) * 2 + 'px')
      })

      it('should set width of big buttons', function() {
        var buttons = this.directive.find('.big_button, .big_button_disabled')
        for (var i = buttons.length - 1; i >= 0; i--) {
          var btn = $(buttons[i])
          expect(btn.width()).toEqual(this.eachBoxesWidth)
        }
      })

      it('should set width of small buttons', function() {
        var small_button_space = 18;
        var small_button_border_size = 1;
        var eachSmallButtonWidth = ((this.eachBoxesWidth - small_button_space) / 2) - (small_button_border_size * 2);
        var buttons = this.directive.find('.small_button, .small_button_disabled')
        for (var i = buttons.length - 1; i >= 0; i--) {
          var btn = $(buttons[i])
          expect(btn.width()).toEqual(eachSmallButtonWidth)
        }
      })

      it('should set width of lol popup', function() {
        expect(this.lolPopUp.css('left')).toEqual(((this.eachBoxesWidth + this.padding) * (this.numVisibleDataBoxes - 1) + ((this.eachBoxesWidth - this.lolPopUp.width()) * 0.5)) + 'px')
      })

      it('should trigger adjust method only once during resizing', function() {
        spyOn(this.scope, 'adjust').and.callThrough()
        spyOn(this.$timeout, 'cancel').and.callThrough()
        $(this.$window).triggerHandler('resize')
        $(this.$window).triggerHandler('resize')
        $(this.$window).triggerHandler('resize')
        this.$timeout.flush()
        expect(this.$timeout.cancel).toHaveBeenCalledTimes(2)
        expect(this.scope.adjust).toHaveBeenCalledTimes(1)
      })

      afterEach(function () {
        this.$timeout.verifyNoPendingTasks()
      })

    })

  })


})();
