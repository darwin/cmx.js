define ['cmx/entity', 'cmx/gizmos/actor_gizmo'], (Entity, ActorGizmo) ->

  class Actor extends Entity
    HEAD_RADIUS: 16

    constructor: (scene, pose) ->
      super(scene)

      # define initial pose
      # p - positional point
      # n - normal definition
      # c - control point
      # l - positional point with reset feature
      # h - handle
      @actorBones = @skelet.addBones [
        ['HNDL',   0,   0, "h"], # handle
        ['HEAD',   0, 106, "n"], # head
        ['NECK',   0,  90, "p"], # body = neck - c1 - c2 - hips
        ['BDC1',   0,  80, "c"],
        ['BDC2',   0,  70, "c"],
        ['HIPS',   0,  50, "p"],
        ['LLEG', -10,  30, "l"], # left leg
        ['LFOT', -10,   0, "p"],
        ['RLEG',  10,  30, "l"], # right leg
        ['RFOT',  10,   0, "p"],
        ['LARM', -10,  70, "l"], # left arm
        ['LHND', -10,  50, "p"],
        ['RARM',  10,  70, "l"], # right arm
        ['RHND',  10,  50, "p"],
      ]

      # define skeleton
      @skelet.addStructure
        'NECK': ['LARM', 'LHND', 'RARM', 'RHND', 'HEAD', 'BDC1']
        'HIPS': ['LLEG', 'LFOT', 'RLEG', 'RFOT', 'BDC2']
        'LARM': ['LHND']
        'RARM': ['RHND']
        'LLEG': ['LFOT']
        'RLEG': ['RFOT']
        'HNDL': ['HEAD', 'NECK', 'BDC1', 'BDC2', 'HIPS', 'LLEG', 'LFOT', 'RLEG', 'RFOT', 'LARM', 'LHND', 'RARM', 'RHND']

      # recognize legs and arms
      @legs = [
        ['HIPS', 'LLEG', 'LFOT'] # left
        ['HIPS', 'RLEG', 'RFOT'] # right
      ]
      @arms = [
        ['NECK', 'LARM', 'LHND'] # left
        ['NECK', 'RARM', 'RHND'] # right
      ]

      # define some heads
      standardHead = =>
        @scene.renderer.circle @HEAD_RADIUS, t:"translate(0, #{@HEAD_RADIUS})"

      @heads =
        "normal": ->
          standardHead()
        "line": ->
          standardHead()
          @scene.renderer.line [[0, 20], [0, 40]]

      @head = "normal"

      @setPose(pose) if pose

    buildGizmo: (root) ->
      @gizmo = new ActorGizmo @, root

    setPose: (pose) ->
      @skelet.setPose pose, @actorBones

    getPose: ->
      @skelet.getPose @actorBones

    drawBody: ->
      bone = (name) => @skelet.bone name

      # smooth bezier with two control points
      bodyPath = =>
        f = (n) -> " #{bone(n).x},#{bone(n).y}"
        "M#{f 'NECK'} C#{f 'BDC1'}#{f 'BDC2'}#{f 'HIPS'}"
      @register @scene.renderer.path (=> bodyPath())

    drawHead: ->
      bone = (name) => @skelet.bone name

      # TODO: heads should be customizable in the future
      @openFrame (=> @prepareFrame(bone('NECK'), bone('HEAD')))
      @heads[@head].apply @
      @closeFrame()

    drawLegs: ->
      bonePos = (name) =>
        bone = @skelet.bone name
        [bone.x, bone.y]

      @register @scene.renderer.line (=> @legs[0].map bonePos)
      @register @scene.renderer.line (=> @legs[1].map bonePos)

    drawArms: ->
      bonePos = (name) =>
        bone = @skelet.bone name
        [bone.x, bone.y]

      @register @scene.renderer.line (=> @arms[0].map bonePos)
      @register @scene.renderer.line (=> @arms[1].map bonePos)

    drawLayer: (layer) ->
      super

      @drawHead() if layer is 2
      @drawBody() if layer is 2
      @drawArms() if layer is 2
      @drawLegs() if layer is 2