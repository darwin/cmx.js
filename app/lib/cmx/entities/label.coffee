define ['cmx/entity', 'cmx/gizmos/label_gizmo'], (Entity, LabelGizmo) ->

  class Label extends Entity

    constructor: (scene, content) ->
      super(scene)

      @labelBones = @skelet.addBones [
        ['HNDL',   0,    0, "h"], # handle
        ['TEXT', -60,    0, "t"], # text origin
      ]

      @skelet.addStructure
        'HNDL': ['TEXT']

      @setContent content

    buildGizmo: (root) ->
      @gizmo = new LabelGizmo @, root

    setPose: (pose) ->
      @skelet.setPose pose, @labelBones

    getPose: ->
      @skelet.getPose @labelBones

    setContent: (@content) ->

    drawText: ->
      f = (bone) => " #{bone.x},#{bone.y}"
      @register @scene.renderer.openGroup t:(=> "translate (#{f @skelet.bone 'TEXT'})")
      @register @scene.renderer.text @content, border:yes
      @register @scene.renderer.closeGroup()

    drawLayer: (layer) ->
      super

      @drawText() if layer is 0 # draw in non-zoomable layer on top frame