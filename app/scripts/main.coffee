require.config
  paths:
    'jquery': 'vendor/jquery'
    'd3': '../components/d3/d3'
    'svginnerhtml': 'vendor/svginnerhtml'
    'backbone': '../components/backbone/backbone'
    'underscore': '../components/underscore-amd/underscore'
    'underscore.string': '../components/underscore.string/lib/underscore.string'
    'cmx': '../app/lib/cmx'

require [
  'jquery',
  'd3',
  'underscore',
  'underscore.string',
  'svginnerhtml',
  'cmx'
], (_jq, _d3, underscore, underscore_string, _svginnerhtml, cmx) ->
  console.log "cmx loaded"
  $("body").trigger("cmx:loaded", cmx)

  # underscore.string could be loaded before underscore, force mixing here
  underscore.string = underscore.str = underscore_string

  # extend d3 with convenience functions
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

  launch = ->
    window.cmx = cmx # TODO: conditionally leak cmx into global scope
    console.log "cmx launched"
    $("body").trigger("cmx:launched", cmx)
    parser = new cmx.Parser(cmx)
    scenes = parser.parseDoc($("body"))

    for sceneModel in scenes
      $scene = $(sceneModel.source)
      console.log "model for ##{$scene.attr("id")}:", @
      sceneModel.debugReport(2)
      sceneModel.materialize $scene

    console.log "cmx ready", cmx
    $("body").trigger("cmx:ready", cmx)
    parent?.messageFromCMX?("cmx:ready", cmx)

  window.WebFontConfig =
    custom:
      families: ["xkcd"]
    active: ->
      launch()

  wf = document.createElement("script")
  wf.src = "scripts/vendor/webfont.js"
  wf.type = "text/javascript"
  wf.async = "true"
  s = document.getElementsByTagName("script")[0]
  s.parentNode.insertBefore wf, s