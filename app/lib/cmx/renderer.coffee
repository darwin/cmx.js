define ['cmx/XKCD'], (XKCD) ->

  # magic evaluator
  ξ = (thing, fn) ->
    lastVal = undefined
    return ->
      val = thing
      val = val() while _.isFunction val
      return val if _.isEqual val, lastVal
      fn? val
      lastVal = val

  # execute a render call (call properties are bound to this)
  render = (Δroot, back=no, Δbefore) ->
    @updaters or= []

    # dynamic props can be updated later via update() call
    dynamic = (prop, updater) =>
      return if prop is undefined
      evaluator = ξ prop, updater
      @updaters.push evaluator
      evaluator

    if @type is "close group"
      return d3.select(Δroot.node().parentNode)

    Δel = Δroot
    Δel = Δel.insert("g", Δbefore) if Δbefore
    Δel = Δel.append("g")
    Δel.attr("class", @["class"]) if @["class"]
    Δel.property "cmx", @["data"] if @["data"]
    dynamic @["t"], (val) -> Δel.attr("transform", val) if val

    # grouping
    if @type is "open group"
      return Δel

    # render text
    if @type is "text"
      Δel = Δel.append("g").attr("transform", "scale(1, -1)") # flip y
      if back
        Δtext = Δel.append("text").attr("class", "cmx-text")
        textUpdater = dynamic @["text"], (val) -> Δtext.html val
        dynamic @["stroke-width"], (val) -> Δtext.style("stroke-width", val) if val
        dynamic @["bgcolor"], (val) -> Δtext.style("stroke", val) if val

        if @["border"]
          textUpdater() # this is needed for getBBox call
          bbox = Δtext.node().getBBox()
          ex = @["border-extrude-x"] or 8
          ey = @["border-extrude-y"] or 3
          polyline =
            type: "polyline"
            points: [
              [bbox.x - ex, bbox.y - ey]
              [bbox.x + bbox.width + ex, bbox.y - ey]
              [bbox.x + bbox.width + ex, bbox.y+bbox.height + ey]
              [bbox.x - ex, bbox.y+bbox.height + ey]
            ]
            "class": "cmx-text-border"
            "fill": @["border-fill"]
            "stroke-width": @["border-stroke-width"]
            "stroke": @["border-stroke"]
            "bgcolor": @["border-bgcolor"]
            closed: yes
          render.call polyline, Δel
          @updaters.push ->
            for updater in polyline.updaters
              updater()

      else # front
        Δtext = Δel.append("text").attr("class", "cmx-text")
        dynamic @["text"], (val) -> Δtext.html val
      return Δroot

    # render polyline
    xl = @['xl'] or [0, 200]
    yl = @['yl'] or [0, 200]
    line = @['line'] or d3.svg.line()
    magnitude = @["magnitude"] or 0.003

    xkcd = new XKCD

    xkcdInterpolator = (pts) =>
      res = xkcd.render pts, xl, yl, magnitude
      res += "Z" if @["fill"] or @closed
      res

    backInterpolator = (pts) =>
      # two decimal places "should be enough for everyone"
      r = (num) -> Math.round(num*100)/100
      result = pts.map (d) ->
        [r(d[0]), r(d[1])]
      result.join("L")

    Δpath = Δel.append("path").attr("class", "cmx-path")
    dynamic @["fill"], (val) -> Δpath.style("fill", val) if val
    if back
      dynamic @["back-stroke-width"], (val) -> Δpath.style("stroke-width", val) if val
      dynamic @["back-stroke"], (val) -> Δpath.style("stroke", val) if val
      dynamic @["points"], (val) -> Δpath.attr("d", line.interpolate(backInterpolator)(val))
    else
      dynamic @["stroke-width"], (val) -> Δpath.style("stroke-width", val) if val
      dynamic @["stroke"], (val) -> Δpath.style("stroke", val) if val
      dynamic @["points"], (val) -> Δpath.attr("d", line.interpolate(xkcdInterpolator)(val))

    Δroot

  class Renderer

    constructor: (root, @width, @height, @marginX=20, @marginY=20) ->
      @calls = []
      fullWidth = @width + 2 * @marginX
      fullHeight = @height + 2 * @marginY

      @Δsvg = d3.select(root).append("svg").attr("class", "cmx-canvas")
      @Δsvg.attr("width", fullWidth).attr("height", fullHeight) # svg canvas
      @Δel = @Δsvg.append("g").attr("transform", "translate(" + @marginX + ", " + @marginY + ")") # implement margin
                  .append("g").attr("transform", "translate(0, " + @height + ") scale(1, -1)") # flip y
      @Δlayers = @Δel.append("g").attr("class", "cmx-layers")

    draw: (Δelement) ->
      Δelement = @Δlayers.append("g").attr("class", "static") unless Δelement

      # draw background line
      Δ = Δelement.append("g").attr("class", "cmx-back")
      for item in @calls
        Δ = render.call item, Δ, yes

      # draw foreground line
      Δ = Δelement.append("g").attr("class", "cmx-front")
      for item in @calls
        Δ = render.call item, Δ, no

      # collect all updaters and wrap them into one updater() function
      for item in @calls
        item.update = ->
          return unless @.updaters
          for update in @.updaters
            update()

      # call initial update on all items
      for item in @calls
        item.update()

      # empty the queue
      @calls = []

      Δelement

    pushCall: (type, opts={}) ->
      opts["type"] = type
      @calls.push opts
      opts

    openGroup: (opts={}) ->
      @pushCall "open group", opts

    closeGroup: (opts={}) ->
      @pushCall "close group", opts

    text: (text, opts={}) ->
      opts["text"] = text
      @pushCall "text", opts

    line: (points, opts={}) ->
      opts["points"] = points
      @pushCall "polyline", opts

    circle: (radius, opts={}) ->
      N = opts["N"] or 20
      R = opts["radians"] or 2 * Math.PI
      angle = d3.scale.linear().domain([0, N - 1]).range([0, R])
      l = d3.svg.line.radial().interpolate("basis").tension(0).radius(radius).angle((d, i) -> angle i)
      @path(l(d3.range(N)), opts)

    path: (spec, opts={}) ->

      lazyEvaluation = =>
        path = document.createElementNS("http://www.w3.org/2000/svg", "path")
        d3.select(path).attr("d", spec)

        # sample the path
        len = path.getTotalLength()
        points = []

        delta = 1.0
        t = 0.0
        while t < len
          p = path.getPointAtLength t
          points.push [p.x, p.y]
          t += delta

        p1 = path.getPointAtLength len
        points.push [p1.x, p1.y]

        # reduce points
        precision = 10 * (Math.PI / 180) # 10 degrees tollerance
        minLen = 0.1

        norm = (v) ->
          l = Math.sqrt(v[0]*v[0] + v[1]*v[1])
          return if l < minLen
          [v[0]/l, v[1]/l]

        flat = (a, m, b) ->
          va = norm [m[0] - a[0], m[1] - a[1]]
          vb = norm [m[0] - b[0], m[1] - b[1]]
          return yes if !va or !vb
          dot = va[0]*vb[0] + va[1]*vb[1]
          dot = 1.0 if dot > 1.0
          dot = -1.0 if dot < -1.0
          angle = Math.acos(dot)
          Math.abs(angle - Math.PI) < precision

        points2 = [points[0]]
        i = 1
        while i < points.length-1
          left = points2[points2.length-1]
          mid = points[i]
          right = points[i+1]
          points2.push mid unless flat(left, mid, right)
          i++

        # add last point
        points2.push points[points.length-1]
        # reduce last 3 points
        if points2.length>=3
          points2.splice(points2.length-2, 1) if flat(points2[points2.length-3], points2[points2.length-2], points2[points2.length-1])

        lastPoints = points2

      @line lazyEvaluation, opts