define ['cmx/model', 'cmx/entities/drawing'], (Model, Drawing) ->

  DEFAULT_LAYER = 2

  class DrawingModel extends Model

    constructor: ->
      @defaults =
        "t": ""
        "pose": "0,0"
        "drawlist": [[], "array"]

      super

    applyDefaults: (props) ->
      super

      # this is our mini-parser for drawing's content
      if props["content"]
        list = []
        $parser = $("<div/>").html(props["content"])
        $parser.children().each ->
          $command = $ @

          collectOpts = ($el) ->
            res = {}
            for attr in $el.get(0).attributes
              key = attr.name.toLowerCase()
              val = attr.value
              res[key] = val

            res

          layer = parseInt($command.attr("layer") or DEFAULT_LAYER, 10)
          action = $command.prop('tagName').toLowerCase()

          cmd = [layer, action]
          switch action
            when 'line'
              points = []
              $command.find("point").each ->
                $point = $ @
                x = parseInt($point.attr("x") or 0, 10)
                y = parseInt($point.attr("y") or 0, 10)
                points.push [x, y]
              cmd.push points

          cmd.push collectOpts($command)

          list.push cmd

        props["drawlist"] = list

      props

    materialize: (parent) ->
      o = new Drawing parent.scene, @props["drawlist"]
      o.setFrame @props["t"]
      o.setPose @unserializePose(@props["pose"])
      parent.add o

      super o

    read: ->
      @props["t"] = @view.getFrame()
      @props["pose"] = @serializePose(@view.getPose())
