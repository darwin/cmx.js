define ->

  class View

    constructor: (@scene) ->
      @subviews = []

    add: (view) ->
      view.parentView = @
      @subviews.push view
      view
