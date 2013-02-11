define ['cmx/model', 'cmx/entities/bubble'], (Model, Bubble) ->

  class BubbleModel extends Model

    constructor: ->
      @defaults =
        "t": ""
        "pose": "0,0|-20,10|-40,50|0,50|-20,90|-60,85"
        "content": '<tspan x="0" y="0em">hello world</tspan>'
        "attach": "head"
      super

    materialize: (parent) ->
      o = new Bubble parent.scene
      o.setFrame @props["t"]
      o.setPose @unserializePose(@props["pose"])
      o.setContent @props.content
      o.setAttachBone @props.attach
      parent.add o

      super o

    read: ->
      @props["t"] = @view.getFrame()
      @props["pose"] = @serializePose(@view.getPose())
