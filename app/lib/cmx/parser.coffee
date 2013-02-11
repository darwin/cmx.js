define [
  "cmx/models/scene_model",
  "cmx/models/actor_model",
  "cmx/models/bubble_model",
  "cmx/models/drawing_model",
  "cmx/models/label_model"
], (modelClasses...) ->
  # TODO: make public API for adding new models
  defaultModels = {}
  for klass in modelClasses
    defaultModels[klass.name] = klass

  class Parser

    constructor: (@cmx, @models = defaultModels) ->

    createFrame: ->
      @$frame = $ "<iframe>",
        "class": "cmx-parser"
        frameborder: 0
        style: "display:none"

      @$frame.appendTo "body"
      @doc = @$frame.contents().get(0)

    writeContent: (markup) ->
      @doc.open()
      @doc.write(markup)
      @doc.close()

    parseMarkup: (markup) ->
      @createFrame()
      @writeContent(markup)
      @parseDoc(@doc)

    lookupModelClass: (modelName) ->
      @models["#{modelName}Model"]

    collectProps: ($el) ->
      res = {}

      # special content attribute captures innerHTML
      content = $el.html()
      res["content"] = content if content

      # attributes may be applied via CSS content property
      content = _.str.trim($el.css('content'), " \t\n'")
      if content and content isnt "none" # Firefox returns "none"
        content = "{#{content}}" if content[0]!="{"
        try
          params = $.parseJSON content # TODO: use some non-strict parser for JSON-like data
          $.extend res, params
        catch e
          console.error e

      # collect native attributes
      for attr in $el.get(0).attributes
        key = attr.name.toLowerCase()
        val = attr.value
        res[key] = val

      res

    parseElement: ($el) ->
      model = $el.data('cmx-model')

      unless model
        tag = _.str.classify $el.prop('tagName').toLowerCase()

        modelClass = @lookupModelClass tag
        unless modelClass
          # console.error "Unknown cmx tag encountered at ", $el[0]
          return

        model = new modelClass @cmx
        model.source = $el.get(0)
        $el.data('cmx-model', model)

      props = @collectProps($el)
      model.set props
      model

    parseDoc: (doc) ->
      $doc = $ doc

      walk = ($el) =>
        model = @parseElement $el

        for child in $el.children()
          $child = $ child
          childModel = walk $child
          continue unless childModel
          childModel.parent = model
          model.children.push childModel

        model

      res = []
      for scene in $doc.find("scene")
        $scene = $ scene
        sceneModel = walk $scene
        sceneModel.source = scene
        res.push sceneModel

      @cmx.scenes = res
      res