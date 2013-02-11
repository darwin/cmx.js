define ['cmx/drawable', 'cmx/gizmos/entity_gizmo', 'cmx/skelet'], (Drawable, EntityGizmo, Skelet) ->

  class Entity extends Drawable

    constructor: (scene) ->
      super(scene)

      @skelet = new Skelet

    setFrame: (@t) ->

    getFrame: ->
      # strip defaults and make the transformation human-readable
      re = /\)([^ ])/
      _.str.trim(
        @t.replace("translate(0,0)", "")
          .replace("rotate(0)", "")
          .replace("skewX(0)","")
          .replace("scale(1,1)", "")
          .replace(re, ") $1")
      )

    getEffectiveFrame: ->
      frame = []
      boneFrame = @getAttachBoneFrame()
      frame.push boneFrame if boneFrame
      frame.push @t
      frame.join("")

    getAttachBoneFrame: ->
      attachBone = @parentView.skelet.bone @attachBone if @attachBone and @parentView.skelet
      @prepareFrame attachBone

    openLayer: (layer) ->
      @openFrame (=> @getEffectiveFrame()),
        "class": "cmx-entity cmx-#{@constructor.name.toLowerCase()}"
        "data":
          "entity": @

    drawLayer: (layer) ->
      # nothing to do here

    closeLayer: (layer) ->
      @closeFrame()

    setAttachBone: (boneName) ->
      @attachBone = boneName.toUpperCase()

    buildGizmo: (root) ->
      @gizmo = new EntityGizmo @, root

    highlightBones: (root, bones=[]) ->
      return unless root
      root.selectAll(".cmx-control").each (d, bone) ->
        d3.select(@).classed("cmx-highlighted-bone", yes) if d.name in bones

    unhighlightBones: (root) ->
      return unless root
      root.selectAll(".cmx-highlighted-bone").each (d, bone) ->
        d3.select(@).classed("cmx-highlighted-bone", no)