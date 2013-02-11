define ->

  class Overlay

    constructor: (root, @width, @height, @marginX, @marginY, @extensionX=400, @extensionY=400) ->
      fullWidth = @width + 2 * @marginX
      fullHeight = @height + 2 * @marginY

      @Δsvg = d3.select(root).append("svg").attr("class", "cmx-overlay").style("left", -@extensionX).style("top", -@extensionY)
      @Δsvg.attr("width", fullWidth+2*@extensionX).attr("height", fullHeight+2*@extensionY) # svg canvas
      @Δdefs = @Δsvg.append("svg:defs")
      @Δel = @Δsvg.append("g").attr("transform", "translate(" + (@marginX+@extensionX) + ", " + (@marginY+@extensionY) + ")") # implement margin
                  .append("g").attr("transform", "translate(0, " + @height + ") scale(1, -1)") # flip y
      @Δgizmos = @Δel.append("g").attr("class", "cmx-gizmos")

      @renderArrowDefs()

    renderArrowDefs: ->
      @Δdefs.append("svg:marker")
        .attr("id", "cmx-end-marker-arrow")
        .attr("class", "cmx-marker-arrow")
        .attr("viewBox", "0 0 10 10")
        .attr("refX", 5)
        .attr("refY", 5)
        .attr("cmx-markerUnits", "strokeWidth")
        .attr("cmx-markerWidth", 3)
        .attr("cmx-markerHeight", 3)
        .attr("orient", "auto")
          .append("svg:path")
          .attr("d", "M 0 0 L 10 5 L 0 10 z")

      @Δdefs.append("svg:marker")
        .attr("id", "cmx-start-marker-arrow")
        .attr("class", "cmx-marker-arrow")
        .attr("viewBox", "0 0 10 10")
        .attr("refX", 5)
        .attr("refY", 5)
        .attr("cmx-markerUnits", "strokeWidth")
        .attr("cmx-markerWidth", 3)
        .attr("cmx-markerHeight", 3)
        .attr("orient", "auto")
          .append("svg:path")
          .attr("d", "M 10 0 L 0 5 L 10 10 z")
