require.config
  paths:
    'jquery': 'vendor/jquery'
    'd3': 'vendor/d3/d3'
    'svginnerhtml': 'vendor/svginnerhtml'
    'underscore': 'vendor/underscore-amd/underscore'
    'underscore.string': 'vendor/underscore.string/lib/underscore.string'
    'cmx': '../../app/lib/cmx'
    'd3ext': 'd3ext'

require [
  'jquery',
  'd3',
  'd3ext',
  'underscore',
  'underscore.string',
  'svginnerhtml',
  'cmx'
], (_jq, _d3, d3ext, underscore, underscoreString, _svginnerhtml, cmx) ->

  publishEvent = (name) ->
    console.log "#{name}"
    $("body").trigger(name, cmx)
    parent?.messageFromCMX?(name, cmx)

  loadWebFonts = (continuation) ->
    alreadyCalled = no

    window.WebFontConfig =
      custom:
        families: ["xkcd"]
      active: ->
        alreadyCalled = yes
        continuation?()

    wf = document.createElement("script")
    wf.src = "//ajax.googleapis.com/ajax/libs/webfont/1/webfont.js"
    wf.type = "text/javascript"
    wf.async = "true"
    s = document.getElementsByTagName("script")[0]
    s.parentNode.insertBefore wf, s

    # for some reason webfont loader does not work on Firefox/Mac when called from IFRAME
    checkIfLoaderIsBroken = ->
      continuation?() unless alreadyCalled

    setTimeout checkIfLoaderIsBroken, 2000

  launch = ->
    cmx.previousCmx = window.cmx
    window.cmx = cmx

    publishEvent("cmx:launched")
    parser = new cmx.Parser(cmx)
    sceneModels = parser.parseDoc($("body"))

    for sceneModel in sceneModels
      $scene = $(sceneModel.source)
      console.log "model for ##{$scene.attr("id")}:", @
      sceneModel.debugReport(2)
      sceneModel.materialize $scene

    publishEvent("cmx:ready")

  publishEvent("cmx:loaded")

  # underscore.string could be loaded before underscore, force mixing here
  underscore.string = underscore.str = underscoreString

  # extend d3 with convenience functions
  d3ext()

  # note: without fonts being fully loaded we would get wrong metrics for label frames
  loadWebFonts(launch)