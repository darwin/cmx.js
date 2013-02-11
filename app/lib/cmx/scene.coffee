define ['cmx/drawable', 'cmx/renderer', 'cmx/overlay', 'cmx/gizmo'], (Drawable, Renderer, Overlay, Gizmo) ->

  class Scene extends Drawable

    constructor: (@cmx, @rootElement, @width=300, @height=400, @frame=yes, @marginX=20, @marginY=20) ->
      super(@)
      @renderer = new Renderer(@rootElement, @width, @height, @marginX, @marginY)
      @

    drawScene: () ->
      @renderer.Δlayers.selectAll("g").remove()
      layers = [ # from top to bottom
        d3.select(document.createElementNS(d3.ns.prefix.svg, "g")).attr("class", "cmx-layer cmx-layer-0") # special non-zoomable layer, goes on top of frame
        d3.select(document.createElementNS(d3.ns.prefix.svg, "g")).attr("class", "cmx-layer cmx-layer-1")
        d3.select(document.createElementNS(d3.ns.prefix.svg, "g")).attr("class", "cmx-layer cmx-layer-2")
      ]

      for layerId in [layers.length-1..0]
        if layerId is 0 and @frame
          Δg = d3.select(document.createElementNS(d3.ns.prefix.svg, "g"))
          Δg.attr("class", "cmx-layer cmx-layer-frame")
          Δlayer = Δg.append("g")
          Δlayer.attr("class", "cmx-pseudo-entity cmx-frame")
          @renderer.Δlayers.node().appendChild Δlayer.node().parentNode
          @drawFrame Δlayer

        Δlayer = layers[layerId]
        @renderer.Δlayers.node().appendChild Δlayer.node()

        for view in @subviews
          Δentity = d3.select(document.createElementNS(d3.ns.prefix.svg, "g")).attr("class", "cmx-entity-tree")
          Δlayer.node().appendChild Δentity.node()
          view.draw layerId
          @renderer.draw Δentity

    triggerUpdateEvent: ->
      $(@rootElement).trigger("cmx:updated")

    announceUpdate: _.throttle(@::triggerUpdateEvent, 2000)

    buildGizmos: ->
      @overlay = new Overlay(@rootElement, @width, @height, @marginX, @marginY)

      super(@overlay.Δgizmos)

      @renderer.Δlayers.selectAll(".cmx-entity")
        .on "click", (event) ->
          gizmo = @cmx?.entity?.gizmo
          if gizmo
            gizmo.select()
            d3.event.stopPropagation()


    drawFrame: (Δwhere) ->
      thickness = 0

      frame = [
        [thickness, thickness]
        [@width - thickness, thickness]
        [@width - thickness, @height - thickness]
        [thickness, @height - thickness]
        [thickness, thickness]
      ]
      @renderer.line(frame)
      @renderer.draw(Δwhere)