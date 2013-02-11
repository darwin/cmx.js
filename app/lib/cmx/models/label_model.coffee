define ['cmx/model', 'cmx/entities/label'], (Model, Label) ->

  class LabelModel extends Model

    constructor: ->
      @defaults =
        "t": ""
        "pose": "0,-10|0,0"
        "content": '<tspan x="0" y="0em">hello world</tspan>'
      super

    materialize: (parent) ->
      o = new Label parent.scene
      o.setFrame @props["t"]
      o.setPose @unserializePose(@props["pose"])
      o.setContent @props.content
      parent.add o

      super o

    read: ->
      @props["pose"] = @serializePose(@view.getPose())
      @props["t"] = @view.getFrame()
