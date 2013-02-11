define ->

  class Model

    constructor: (@cmx) ->
      @children = []
      @props = @applyDefaults? {}
      @mutableProps = ["t", "pose"] # props editable via Gizmo UI

    set: (props) ->
      # apply defaults
      props = @applyDefaults? props

      # filter unknown properties
      props = _.pick(props, _.keys(@defaults))

      # coerce possible string values to known types
      props = @coerceTypes? props

      # apply to self
      _.extend @props, props

      # TODO: notification event triggering here?

    unserializePose: (poseString) ->
      items = poseString.split "|"
      items.map (pair) ->
        pair.split(",").map (numString) -> parseFloat(numString)

    serializePose: (pose) ->
      pairs = pose.map (pair) -> pair.join(",")
      pairs.join "|"

    computeDefaults: ->
      defaults = {}
      for key, val of @defaults
        val = val[0] if _.isArray val
        defaults[key] = val
      defaults

    applyDefaults: (props) ->
      defaults = @computeDefaults()
      _.defaults(props, defaults)
      props

    coerceTypes: (props) ->
      res = {}
      for key, val of props
        def = @defaults[key]
        continue if def is undefined
        type = def[1] || "string"
        res[key] = switch type
          when "s", "string" then ""+val
          when "i", "int" then parseInt(val, 10) or 0
          when "f", "float" then parseFloat(val) or 0.0
          when "a", "array" then val # TODO: validate array structure
          when "b", "bool"
            if _.isString val
              val.match(/^(true|1|yes)$/i) isnt null
            else
              !!val
          else val

      res

    read: ->

    writeProps: (props, $source) ->
      defaults = @computeDefaults()
      for prop, val of _.pick(props, @mutableProps)
        if val is defaults[prop]
          $source.removeAttr(prop)
        else
          $source.attr(prop, val)

    serialize: ->
      @read()
      @writeProps(@props, $(@source))

      for child in @children
        child.serialize()
      @

    materialize: (newborn) ->
      for child in @children
        child.materialize newborn
      @view = newborn

    debugReport: (indent=0, logger=console) ->
      indenting = [0...indent].map(-> " ").join("")
      displayableProps = _.clone(@props)
      # collapse content if it is a multi-line string
      displayableProps["content"] = "..." if _.isString(displayableProps["content"]) and displayableProps["content"].indexOf("\n")!=-1
      logger.log "#{indenting}#{@.constructor.name}", displayableProps

      for child in @children
        child.debugReport indent+2, logger