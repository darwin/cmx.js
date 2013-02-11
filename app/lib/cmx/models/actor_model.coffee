define ['cmx/model', 'cmx/entities/actor'], (Model, Actor) ->

  class ActorModel extends Model

    constructor: ->
      @defaults =
        "t": ""
        "pose": "0,0|0,106|0,90|0,80|0,70|0,50|-10,30|-10,0|10,30|10,0|-10,70|-10,50|10,70|10,50"

      super

    materialize: (parent) ->
      o = new Actor parent.scene
      o.setFrame @props["t"]
      o.setPose @unserializePose(@props["pose"])
      parent.add o

      super o

    read: ->
      @props["t"] = @view.getFrame()
      @props["pose"] = @serializePose(@view.getPose())
