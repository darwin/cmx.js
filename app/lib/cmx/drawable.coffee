define ['cmx/view'], (View) ->

  class Drawable extends View

    constructor: (scene) ->
      @renderCalls = []
      super(scene)

    register: (renderCall) ->
      @renderCalls.push renderCall
      renderCall

    draw: (layer) ->
      @openLayer?(layer)
      @drawLayer?(layer)
      for view in @subviews
        view.draw(layer)
      @closeLayer?(layer)

    prepareFrame: (framePos, frameRot) ->
      r = (num) -> Math.round(num)
      f = (p) -> "#{r p.x},#{r p.y}"
      frame = []
      frame.push "translate(#{f framePos})" if framePos

      if frameRot and framePos
        # point framePos defines position
        # vector framePos -> frameRot defines rotation

        vecAngle = (x, y) ->
          len = Math.sqrt(x*x + y*y)
          dot = x / len
          rad = Math.acos(dot)
          angle = rad * (360/(2*Math.PI)) - 90
          angle = 180 - angle if y < 0
          [angle, len]

        vx = frameRot.x - framePos.x
        vy = frameRot.y - framePos.y
        [angle, len] = vecAngle(vx, vy)
        frame.push "rotate(#{r angle})"

      frame.join("")

    openFrame: (frame, opts={}) ->
      opts["t"] = frame
      @register @scene.renderer.openGroup opts

    closeFrame: ->
      @scene.renderer.closeGroup()

    buildGizmo: (root) ->
      leafGizmo: root

    buildGizmos: (root) ->
      newRoot = @buildGizmo?(root)

      for view in @subviews
        view.buildGizmos?(newRoot.leafGizmo)
        view.gizmo.update()

    update: ->
      @gizmo?.update()
      for call in @renderCalls
        call.update()

      @updateDependants()
      @scene.announceUpdate()
      @

    updateDependants: ->
      for view in @subviews
        view.update()
      @

    throttledUpdate: _.throttle(@::update, 50)