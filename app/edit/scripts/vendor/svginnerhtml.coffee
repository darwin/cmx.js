((view) ->
  constructors = ["SVGSVGElement", "SVGGElement", "SVGTextElement"]
  dummy = document.createElement("dummy")
  return false  if not constructors[0] of view
  if Object.defineProperty
    innerHTMLPropDesc =
      get: ->
        dummy.innerHTML = ""
        Array::slice.call(@childNodes).forEach (node, index) ->
          dummy.appendChild node.cloneNode(true)

        dummy.innerHTML

      set: (content) ->
        self = this
        parent = this
        allNodes = Array::slice.call(self.childNodes)
        fn = (to, node) ->
          return false  if node.nodeType isnt 1 and node.nodeType isnt 3
          if node.nodeType is 3
            newNode = node
          else
            newNode = document.createElementNS("http://www.w3.org/2000/svg", node.nodeName.toLowerCase())
          if node.attributes
            Array::slice.call(node.attributes).forEach (attribute) ->
              newNode.setAttribute attribute.name, attribute.value

          newNode.textContent = node.innerHTML  if node.nodeName is "TEXT"
          to.appendChild newNode
          if node.childNodes and node.childNodes.length
            Array::slice.call(node.childNodes).forEach (node, index) ->
              fn newNode, node



        # /> to </tag>
        content = content.replace(/<(\w+)([^<]+?)\/>/, "<$1$2></$1>")

        # Remove existing nodes
        allNodes.forEach (node, index) ->
          node.parentNode.removeChild node

        dummy.innerHTML = content
        Array::slice.call(dummy.childNodes).forEach (node) ->
          fn self, node


      enumerable: true
      configurable: true

    try
      constructors.forEach (constructor, index) ->
        Object.defineProperty window[constructor]::, "innerHTML", innerHTMLPropDesc


  # TODO: Do something meaningful here
  else if Object["prototype"].__defineGetter__
    constructors.forEach (constructor, index) ->
      window[constructor]::__defineSetter__ "innerHTML", innerHTMLPropDesc.set
      window[constructor]::__defineGetter__ "innerHTML", innerHTMLPropDesc.get

) window