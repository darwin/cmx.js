define ['cmx/entity', 'cmx/gizmos/bubble_gizmo'], (Entity, BubbleGizmo) ->

  class Bubble extends Entity

    constructor: (scene, content) ->
      super(scene)

      # define initial pose
      # p - positional point
      # c - control point
      # h - handle
      @bubbleBones = @skelet.addBones [
        ['HNDL',   0,    0, "h"], # handle
        ['LINE', -20,   10, "p"], # line = start - c1 - c2 - end
        ['LCP1', -40,   50, "c"],
        ['LCP2',   0,   50, "c"],
        ['LEND', -20,   90, "p"],
        ['TEXT', -80,  130, "t"], # text origin
      ]

      @skelet.addStructure
        'HNDL': ['LINE', 'LCP1', 'LCP2', 'LEND', 'TEXT']
        'LEND': ['LCP2']
        'LINE': ['LCP1']

      @setContent content

    buildGizmo: (root) ->
      @gizmo = new BubbleGizmo @, root

    setPose: (pose) ->
      @skelet.setPose pose, @bubbleBones

    getPose: ->
      @skelet.getPose @bubbleBones

    setContent: (@content) ->

    drawLine: ->
      bone = (name) => @skelet.bone name

      # smooth bezier with two control points
      bodyPath = =>
        f = (n) => " #{bone(n).x},#{bone(n).y}"
        "M#{f 'LINE'} C#{f 'LCP1'}#{f 'LCP2'}#{f 'LEND'}"
      @register @scene.renderer.path (=> bodyPath()), "stroke-width":2

    drawText: ->
      f = (bone) => " #{bone.x},#{bone.y}"
      @register @scene.renderer.openGroup t: (=> "translate (#{f @skelet.bone 'TEXT'})")
      @register @scene.renderer.text @content
      @register @scene.renderer.closeGroup()

    drawLayer: (layer) ->
      super

      @drawLine() if layer is 2
      @drawText() if layer is 1