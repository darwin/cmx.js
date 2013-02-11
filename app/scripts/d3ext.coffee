define ->

  ->
    d3.selection.prototype.parents = (selector) ->
      res = []
      p = this.node()
      while p = p.parentNode
        try
          klass = d3.select(p).attr("class")
        catch e

        continue unless klass
        items = klass.split(" ")
        res.push p if selector in items

      res
