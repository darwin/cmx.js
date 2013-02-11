define ['cmx/entity', 'cmx/gizmos/drawing_gizmo'], (Entity, DrawingGizmo) ->

  class Drawing extends Entity

    constructor: (scene, drawlist=[]) ->
      # HACK: find proper way how to do deep clone
      @drawlist = drawlist.map (call) -> call.map (x) -> _(x).clone()
      super(scene)

      @drawingBones = @skelet.addBones [
        ['HNDL',   0,    0, "h"], # handle
      ]

    buildGizmo: (root) ->
      @gizmo = new DrawingGizmo @, root

    setPose: (pose) ->
      @skelet.setPose pose, @drawingBones

    getPose: ->
      @skelet.getPose @drawingBones

    drawLayer: (layer) ->
      super

      itemsToBeRendered = _(@drawlist).filter (item) -> layer is item[0]
      return unless itemsToBeRendered.length

      @openFrame (=> @prepareFrame(@skelet.bone('HNDL')))
      for item in itemsToBeRendered
        @scene.renderer[item[1]].apply(@scene.renderer, item[2..-1])
      @closeFrame()
