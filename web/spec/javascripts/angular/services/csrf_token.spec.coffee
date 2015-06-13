describe 'CSRFToken Service', ->

  csrf ='test-csrf-string'

  $window = $: ->
    attr: -> csrf

  beforeEach ->

    module 'ChaiBioTech'

    module ($provide) ->
      $provide.value '$window', $window
      return

    inject ($injector) ->

      @httpBackend = $injector.get '$httpBackend'
      @CSRFToken = $injector.get 'CSRFToken'

  it 'should append csrf meta to header', ->
    config = headers: {}
    config = @CSRFToken.request(config)
    expect(config.headers['X-CSRF-Token']).toBe csrf
