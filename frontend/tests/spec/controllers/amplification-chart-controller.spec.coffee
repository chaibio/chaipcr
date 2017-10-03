describe 'AmplificationChartCtrl', ->

  _$httpBackend = null
  _$rootScope = null
  _$controller = null

  beforeEach ->
    module 'ChaiBioTech', ($provide) ->
      mockCommonServices($provide)


    inject ($injector) ->
      _$httpBackend = $injector.get '$httpBackend'
      _$controller = $injector.get '$controller'
      _$rootScope = $injector.get '$rootScope'


  it 'should have AmplificationChartCtrl controller', ->
    expect(ChaiBioTech.AmplificationChartCtrl).not.toEqual(null)

