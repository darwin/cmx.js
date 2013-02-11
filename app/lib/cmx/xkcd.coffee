define ->

  class XKCD

    # taken from: http://dan.iel.fm/xkcd
    # XKCD-style line interpolation. Roughly based on:
    #    jakevdp.github.com/blog/2012/10/07/xkcd-style-plots-in-matplotlib
    render: (points, xlim, ylim, magnitude) ->

      # smooth some data with a given window size
      smooth = (d, w) ->
        result = []
        i = 0
        l = d.length

        while i < l
          mn = Math.max(0, i - 5 * w)
          mx = Math.min(d.length - 1, i + 5 * w)
          s = 0.0
          result[i] = 0.0
          j = mn

          while j < mx
            wd = Math.exp(-0.5 * (i - j) * (i - j) / w / w)
            result[i] += wd * d[j]
            s += wd
            ++j
          result[i] /= s
          ++i
        result

      # scale the data
      f = [xlim[1] - xlim[0], ylim[1] - ylim[0]]
      z = [xlim[0], ylim[0]]
      scaled = points.map (p) ->
        [(p[0] - z[0]) / f[0], (p[1] - z[1]) / f[1]]

      # compute the distance along the path using a map-reduce
      dists = scaled.map (d, i) ->
        return 0.0 if i is 0
        dx = d[0] - scaled[i - 1][0]
        dy = d[1] - scaled[i - 1][1]
        Math.sqrt dx * dx + dy * dy

      sum = (curr, d) -> d + curr
      dist = dists.reduce(sum, 0.0)

      # choose the number of interpolation points based on this distance
      N = Math.round(200 * dist)

      # re-sample the line
      resampled = []
      dists.map (d, i) ->
        return if i is 0
        n = Math.max(3, Math.round(d / dist * N))
        spline = d3.interpolate(scaled[i - 1][1], scaled[i][1])
        delta = (scaled[i][0] - scaled[i - 1][0]) / (n - 1)
        j = 0
        x = scaled[i - 1][0]

        while j < n
          resampled.push [x, spline(j / (n - 1))]
          ++j
          x += delta

      # compute the gradients
      gradients = resampled.map (a, i, d) ->
        return [d[1][0] - d[0][0], d[1][1] - d[0][1]] if i is 0
        return [d[i][0] - d[i - 1][0], d[i][1] - d[i - 1][1]] if i is resampled.length - 1
        [0.5 * (d[i + 1][0] - d[i - 1][0]),
         0.5 * (d[i + 1][1] - d[i - 1][1])]

      # normalize the gradient vectors to be unit vectors
      gradients = gradients.map (d) ->
        len = Math.sqrt d[0] * d[0] + d[1] * d[1]
        [d[0] / len, d[1] / len]

      # generate some perturbations
      perturbations = smooth resampled.map(d3.random.normal()), 3

      # add in the perturbations and re-scale the re-sampled curve
      perturbed = resampled.map (d, i) ->
        p = perturbations[i]
        g = gradients[i]
        [(d[0] + magnitude * g[1] * p) * f[0] + z[0],
         (d[1] - magnitude * g[0] * p) * f[1] + z[1]]

      # two decimal places "should be enough for everyone"
      r = (num) -> Math.round(num*100)/100
      result = perturbed.map (d) ->
        [r(d[0]), r(d[1])]

      result.join "L"