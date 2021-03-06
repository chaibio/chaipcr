
describe 'UserSettings Controller', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @rootScope = $injector.get '$rootScope'
      @$controller = $injector.get '$controller'
      @httpBackend = $injector.get '$httpBackend'

      @httpBackend.expectGET('/users').respond []

      # controller dependencies
      @scope = @rootScope.$new()

      @window =
        location: null
        confirm: ->
          true

      @modal =
        open: ->
          close: ->

      @User = $injector.get 'User'

      @ctrl = @$controller 'UserSettingsCtrl',
        '$scope' : @scope
        '$window': @window
        '$modal' : @modal
        'User'   : @User

      @userMock =
        id: 1
        email: 'pitogo.adones@gmail.com'

  it 'should go home', ->
    @scope.goHome()
    expect(@window.location).toBe '#home'

  it 'should add user', ->
    @httpBackend.expectPOST('/users').respond {user: {}}
    @httpBackend.expectGET('/users').respond [@userMock]
    @scope.modal = close: ->
    closeSpy = spyOn @scope.modal, 'close'
    @scope.user.role = true
    @scope.addUser()
    @httpBackend.flush()
    expect(closeSpy).toHaveBeenCalled()
    expect(@scope.users).toEqual [@userMock]
    expect(@scope.user).toEqual {}

  it 'should reject invalid user', ->
    resp =
      user:
        error:
          email: ['can\'t be blank']
    @httpBackend.expectPOST('/users').respond => [
      422, resp
    ]

    @scope.modal = close: ->
    @scope.user.role = true
    @scope.addUser()
    @httpBackend.flush()
    expect(@scope.user.errors).toEqual resp.user.errors

  it 'should remove user', ->
    @scope.users = [@userMock]
    @httpBackend.expectDELETE("/users/#{@userMock.id}").respond 200
    @scope.removeUser(@userMock.id)
    @httpBackend.expectGET('/users').respond []
    @httpBackend.flush()
    expect(@scope.users).toEqual []

  it 'should open add user modal', ->
    modalOpenSpy = spyOn(@modal, 'open').and.callThrough()
    @scope.openAddUserModal()
    expect(modalOpenSpy).toHaveBeenCalledWith
      scope: @scope
      templateUrl: 'app/views/user/modal-add-user.html'