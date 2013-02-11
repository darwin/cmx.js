define ['cmx/gizmos/entity_gizmo'], (EntityGizmo) ->

  class DrawingGizmo extends EntityGizmo

    update: ->
      super

      @ΔskeletonGizmo?.selectAll(".cmx-control")
        .attr("cx", (bone) -> bone.x)
        .attr("cy", (bone) -> bone.y)
        .style("display", (bone) =>
          return
        )

    build: ->
      base = super

      @ΔskeletonGizmo = base.append("g").attr("class", "cmx-gizmo cmx-drawing")

      resetBone = (bone) =>
        @entity.skelet.moveBone(bone.name, 0, 0, yes)
        @entity.throttledUpdate()

      doubleClick = (bone) =>
        d3.event.preventDefault()
        return resetBone(bone) if bone.name is 'HNDL'

      drag = d3.behavior.drag()
        .on "dragstart", (bone) =>
          @controlUndoOpen "pose"
          @controlDragStart(bone)
        .on "dragend", (bone) =>
          @controlDragEnd(bone)
          @controlUndoClose()
        .on "drag", (bone) =>
          @entity.skelet.moveBone(bone.name, d3.event.dx, d3.event.dy, no)
          @entity.throttledUpdate()

      data = @entity.skelet.bonesWithIndices @entity.drawingBones
      @ΔskeletonGizmo.selectAll(".cmx-control")
        .data(data)
        .enter()
          .append("circle")
            .attr("class", (bone) -> "cmx-control cmx-#{bone.type}")
            .attr("r", @CONTROL_POINT_RADIUS)
            .on("dblclick", doubleClick)
            .call(drag)

      @ΔskeletonGizmo
