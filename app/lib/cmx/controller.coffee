define ['cmx/gizmo'], (Gizmo) ->

  instanceNumber = 0

  class Controller

    constructor: (@scenes=[]) ->
      @instanceNumber = ++instanceNumber
      @undoStack = []
      @redoStack = []

    makeEditable: ->
      for sceneModel in @scenes
        scene = sceneModel.view
        scene.buildGizmos()
        $(scene.rootElement).addClass("cmx-editable")

      $("html").bind("click", (event) =>
        return if (d3.select(event.target).parents("cmx-selected").length>0)
        @unselectAll()
      )

    unselectAll: ->
      return unless @previousSelection
      @previousSelection.unselect()
      @previousSelection = undefined
      $(".cmx-has-selected-gizmo").removeClass("cmx-has-selected-gizmo")
      $("html").removeClass("cmx-active-selection")

    registerUndo: (fn) ->
      @undoStack.push(fn)

    undo: ->
      return unless @undoStack.length
      action = @undoStack.pop()
      action()

    registerRedo: (fn) ->
      @redoStack.push(fn)

    redo: ->
      return unless @redoStack.length
      action = @redoStack.pop()
      action()


