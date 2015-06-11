
describe 'sample', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @rootScope = $injector.get '$rootScope'

  it 'should be true', ->
    expect(true).toBe true