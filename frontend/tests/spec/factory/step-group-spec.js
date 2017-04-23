describe("Testing step group", function() {

  beforeEach(module('ChaiBioTech'));
  beforeEach(module('canvasApp'));

  var _stepGroup, step = {
      left: 500,
      stepRect: {},
      numberingTextCurrent: {},
      numberingTextTotal: {},
      stepName: {},
      deltaSymbol: {},
      deltaGroup: {},
      borderRight: {}
    }, shadowStepGroup;

  beforeEach(inject(function(stepGroup, stepRect, numberingText, deltaSymbol, deltaGroup, stepName, borderRight) {

    shadowStepGroup = stepGroup;
    step = {
        left: 500,
        stepRect: {},
        numberingTextCurrent: {},
        numberingTextTotal: {},
        stepName: {},
        deltaSymbol: {},
        deltaGroup: {},
        borderRight: {}
      };

    step.stepRect = new stepRect(step);
    step.numberingTextCurrent = new numberingText('current');
    step.numberingTextTotal = new numberingText('total');
    step.deltaSymbol = new deltaSymbol();
    step.deltaGroup = new deltaGroup(step);
    step.stepName = new stepName("Jo");
    step.borderRight = new borderRight(step);

    _stepGroup = new stepGroup(step);
  }));
  // [step.stepRect, step.numberingTextCurrent, step.numberingTextTotal, step.numberingTextTotal, step.deltaSymbol,
  //  step.deltaGroup, step.borderRight]
  it("It should check the left property", function() {
    expect(_stepGroup.left).toEqual(step.left);
  });

  it("It should check the left property when no left value is given", function() {
    step.left = null;
    _stepGroup = new shadowStepGroup(step);
    expect(_stepGroup.left).toEqual(33);
  });

  it("It should check the top property", function() {
    expect(_stepGroup.top).toEqual(28);
  });

  it("It should check the selectable property", function() {
    expect(_stepGroup.selectable).toBeFalsy();
  });

  it("It should check the hasControls property", function() {
    expect(_stepGroup.hasControls).toBeFalsy();
  });

  it("It should check the hasBoarders property", function() {
    expect(_stepGroup.hasBoarders).toBeFalsy();
  });

  it("It should check the name property", function() {
    expect(_stepGroup.name).toEqual('stepGroup');
  });

  it("It should check the me property", function() {
    expect(_stepGroup.me).toEqual(jasmine.objectContaining({
      left: 500
    }));
  });

});
