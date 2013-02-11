define ['cmx/model', 'cmx/scene'], (Model, Scene) ->

  class SceneModel extends Model

    constructor: ->
      @defaults =
        "width": [250, "int"]
        "height": [350, "int"]
        "frame": [yes, "bool"]
        "margin-x": [10, "int"]
        "margin-y": [20, "int"]

      super

    applyDefaults: (props) ->
      super

      if props["margin"] isnt undefined
        props["margin-x"] = props["margin"]
        props["margin-y"] = props["margin"]

      props

    materialize: ($where) ->
      $wrapper = $("<div/>").attr('class', 'cmx-scene')
      id = $(@source).attr("id")
      $wrapper.addClass("cmx-user-#{id}") if id
      $where.after $wrapper

      scene = new Scene @cmx, $wrapper.get(0), @props["width"], @props["height"], @props["frame"], @props["margin-x"], @props["margin-y"]
      super scene
      scene.drawScene()
      scene
