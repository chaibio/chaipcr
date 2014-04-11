class ChaiBioTech.Models.Post extends Backbone.Model
  paramRoot: 'post'

  defaults:
    title: null
    content: null

class ChaiBioTech.Collections.PostsCollection extends Backbone.Collection
  model: ChaiBioTech.Models.Post
  url: '/posts'
