define ['cmx/gizmo'], (Gizmo) ->

  MARKER_POS = 0
  MARKER_ROT = 1
  MARKER_SX  = 2
  MARKER_SY  = 3
  MARKER_SQ  = 4

  class EntityGizmo extends Gizmo

    constructor: ->
      @entityMarkers = [
        { kind: "pos", val: [0, 0] }
        { kind: "rot", val: 0 }
        { kind: "sx", val: 1 }
        { kind: "sy", val: 1 }
        { kind: "sq", val: 0 }
      ]

      super

    markerPosition: (marker) ->
      switch marker.kind
        when "pos" then x:0, y:0
        when "rot" then x:15, y:15
        when "sx" then x:10, y:0
        when "sy" then x:0, y:10
        when "sq" then x:marker.val, y:-10
        else throw "unknown marker"

    decomposeFrame: (frame) ->
      t = d3.transform(frame)
      @entityMarkers[MARKER_POS].val[0] = t.translate[0]
      @entityMarkers[MARKER_POS].val[1] = t.translate[1]
      @entityMarkers[MARKER_ROT].val = t.rotate
      @entityMarkers[MARKER_SX].val = t.scale[0]
      @entityMarkers[MARKER_SY].val = t.scale[1]
      @entityMarkers[MARKER_SQ].val = t.skew

    composeFrame: ->
      round = (v, p=1) -> Math.round(v*p)/p

      t = d3.transform()
      t.translate[0] = round @entityMarkers[MARKER_POS].val[0]
      t.translate[1] = round @entityMarkers[MARKER_POS].val[1]
      t.rotate = round @entityMarkers[MARKER_ROT].val
      t.scale[0] = round @entityMarkers[MARKER_SX].val, 100
      t.scale[1] = round @entityMarkers[MARKER_SY].val, 100
      t.skew = round @entityMarkers[MARKER_SQ].val
      t.toString()

    update: ->
      @ΔentityGizmo?.attr("transform", @entity.getEffectiveFrame())
        .selectAll(".cmx-marker")
          .attr("transform", (marker) =>
            pos = @markerPosition(marker)
            "translate(#{pos.x},#{pos.y})"
          )
      @

    build: (root) ->
      base = super

      @ΔentityGizmo = base.append("g").attr("class", "cmx-gizmo cmx-entity")

      doubleClick = (marker) =>
        d3.event.preventDefault()

        switch marker.kind
          when "pos" then marker.val = [0, 0]
          when "rot" then marker.val = 0
          when "sx" then marker.val = 1
          when "sy" then marker.val = 1
          when "sq" then marker.val = 0

        @entity.setFrame @composeFrame()
        @entity.throttledUpdate()

      drag = d3.behavior.drag()
        .base((target) => target.parentNode.parentNode)
        .on "dragstart", (bone) =>
          @controlUndoOpen "frame"
          @controlDragStart(bone)
        .on "dragend", (bone) =>
          @controlDragEnd(bone)
          @controlUndoClose()
        .on "drag", (marker) =>
          @decomposeFrame @entity.getFrame()
          switch marker.kind
            when "pos" then marker.val[0] += d3.event.dx; marker.val[1] += d3.event.dy
            when "rot" then marker.val += d3.event.dx + d3.event.dy
            when "sx" then marker.val += d3.event.dx*0.1
            when "sy" then marker.val += d3.event.dy*0.1
            when "sq" then marker.val += d3.event.dx
          @entity.setFrame @composeFrame()
          @entity.throttledUpdate()

      renderMarker = (marker) ->
        Δ = d3.select(@)

        appendRect = (Δ, x, y, w, h) ->
          Δ.append("rect").attr("x", x).attr("y", y).attr("width", w).attr("height", h)

        appendLine = (Δ, x1, y1, x2, y2) ->
          Δ.append("line").attr("x1", x1).attr("y1", y1).attr("x2", x2).attr("y2", y2)

        unless marker.kind is "rot"
          appendRect Δ, -5, -5, 10, 10

        switch marker.kind
          when "pos" # draw cross
            appendLine Δ, -5, 0, 5, 0
            appendLine Δ, 0, -5, 0, 5
          when "rot" # draw arc with double arrows
            appendRect Δ, -10, -10, 15, 15
            Δ.append("path")
              .attr("transform", "translate(-8, -8)")
              .attr("d", "M0,10 A10 10,0,0,0,10 0")
          when "sx" # draw line with arrow
            appendLine Δ, -5, 0, 5, 0
          when "sy" # draw line with arrow
            appendLine Δ, 0, -5, 0, 5
          when "sq" # draw line with double arrows
            appendLine Δ, -5, 0, 5, 0

      selection = @ΔentityGizmo.selectAll(".cmx-marker")
        .data(@entityMarkers)
        .enter()
          .append("g")
            .attr("class", (marker) -> "cmx-control cmx-marker cmx-#{marker.kind}")
            .on("dblclick", doubleClick)
            .call(drag)
      selection.each(renderMarker)

      @ΔentityGizmo
