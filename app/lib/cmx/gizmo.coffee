define ['cmx/drawable'], (Drawable) ->

  # cached values between controlUndoOpen - controlUndoClose
  initialUndoValue = undefined
  undoEval = undefined

  class Gizmo extends Drawable
    CONTROL_POINT_RADIUS: 3

    constructor: (@entity, root) ->
      super @entity.scene
      @entity.gizmo = @
      @leafGizmo = @build(root)

    build: (root) ->
      @ΔrootGizmo = root.append("g").attr("class", "cmx-gizmo root")

    controlDragStart: (bone) ->
      $(@scene.rootElement).addClass("cmx-something-is-being-dragged")
      @entity.highlightBones(@ΔskeletonGizmo, @entity.skelet.affectedBones(bone.name))
      $("html").addClass("cmx-force-move-cursor")

    controlDragEnd: (bone) ->
      $(@scene.rootElement).removeClass("cmx-something-is-being-dragged")
      @entity.unhighlightBones(@ΔskeletonGizmo)
      $("html").removeClass("cmx-force-move-cursor")

    controlUndoOpen: (what, params...) ->
      getter = "get" + _.str.classify what
      setter = "set" + _.str.classify what

      undoEval = (val) =>
        if val
          @entity[setter].call @entity, val
        else
          @entity[getter].apply @entity, params

      initialUndoValue = undoEval()

    controlUndoClose: ->
      finalUndoValue = undoEval()
      ((original, modified, evaluator) =>
        action = =>
          evaluator(original)
          @entity.throttledUpdate()
          @scene.cmx.registerRedo =>
            evaluator(modified)
            @entity.throttledUpdate()
            @scene.cmx.registerUndo action
        @scene.cmx.registerUndo action
      )(initialUndoValue, finalUndoValue, undoEval)

    unselect: ->
      @ΔentityGizmo.classed("cmx-selected", no)
      @ΔentityGizmo.select(".cmx-force-unselected").classed("cmx-force-unselected", no)

    select: ->
      @scene.cmx.unselectAll()
      @ΔentityGizmo.classed("cmx-selected", yes)
      @ΔentityGizmo.select(".root").classed("cmx-force-unselected", yes)
      $(@scene.rootElement).addClass("cmx-has-selected-gizmo")
      $("html").addClass("cmx-active-selection")
      @scene.cmx.previousSelection = @

