class ChaiBioTech.Routers.PostsRouter extends Backbone.Router
  initialize: (options) ->
    @posts = new ChaiBioTech.Collections.PostsCollection()
    @posts.reset options.posts

  routes:
    "new"      : "newPost"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newPost: ->
    console.log($('#container'))
    @view = new ChaiBioTech.Views.Posts.NewView(collection: @posts)
    $("#container").html(@view.render().el)
    
  index: ->
    @view = new ChaiBioTech.Views.Posts.IndexView(posts: @posts)
    $("#container").html(@view.render().el)

  show: (id) ->
    post = @posts.get(id)

    @view = new ChaiBioTech.Views.Posts.ShowView(model: post)
    $("#container").html(@view.render().el)

  edit: (id) ->
    post = @posts.get(id)

    @view = new ChaiBioTech.Views.Posts.EditView(model: post)
    $("#posts").html(@view.render().el)
