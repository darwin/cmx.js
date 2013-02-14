# http://stackoverflow.com/a/901144/84283
getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  unless results?
    ""
  else
    decodeURIComponent results[1].replace(/\+/g, " ")

getGistUrl = (id) ->
  "https://api.github.com/gists/#{id}"

initializeHelp = ->
  updateHelp = ->
    if $.cookie('help')=="hidden"
      $("#help").css("display", "none")
      $("#help-icon").css("display", "block")
    else
      $("#help").css("display", "block")
      $("#help-icon").css("display", "none")

  updateHelp()
  $("#help .dismiss").on "click", ->
    $.cookie('help', 'hidden', expires: 30)
    updateHelp()
  $("#help-icon .open").on "click", ->
    $.cookie('help', 'shown', expires: 30)
    updateHelp()

updateControls = ->
  if cmxref?.undoStack.length>0
    $("#undo-button").attr("disabled", null)
  else
    $("#undo-button").attr("disabled", "disabled")

  if cmxref?.redoStack.length>0
    $("#redo-button").attr("disabled", null)
  else
    $("#redo-button").attr("disabled", "disabled")

initializeUndoRedo = ->
  $("#undo-button").on "click", ->
    cmxref?.undo()
    updateControls()

  $("#redo-button").on "click", ->
    cmxref?.redo()
    updateControls()

window.messageFromCMX = (event, cmx) ->
  switch event
    when 'cmx:ready'
      window.cmxref = cmx
      cmx.makeEditable()
      updateControls()

class Editor

  constructor: () ->
    @setupAce()

    @$picker = $ '#file-picker'
    @$picker.on 'change', (event) =>
      @selectFile @$picker.val()

    @$apply = $ '#apply'
    @$apply.on 'click', =>
      @saveFile()
      @ace.focus()

  setupAce: ->
    @ace = ace.edit "editor"

    config = require("ace/config")
    config.set("packaged",true)

    path = "scripts/ace"
    config.set("modePath", path)
    config.set("themePath", path)

    @ace.setTheme "ace/theme/chrome"
    @ace.setShowPrintMargin no
    @ace.setShowInvisibles yes
    @ace.setDisplayIndentGuides no
    @ace.setShowFoldWidgets no

    session = @ace.getSession()
    session.setUseSoftTabs yes
    session.setUseWrapMode yes
    session.setTabSize 2
    session.setFoldStyle "manual"
    session.setMode "ace/mode/html"

    @ace.commands.addCommand
      name: 'Save Changes'
      bindKey: { win: 'Ctrl-S', mac: 'Command-S' }
      exec: =>
        @saveFile()
        true

  updateFromModel: (model) ->
    @updateFilePicker model
    @selectFile 0

  updateFilePicker: (model) ->
    @$picker.empty()
    @files = []
    unit_index = 0
    for unit in model
      unit_index++
      for item in unit.items
        continue unless item.content
        @files.push item
        title = "#{@files.length}. #{item.title()}"
        @$picker.append($("<option/>").val(@files.length-1).text(title));

  fileTypeToAceMode: (type) ->
    "ace/mode/#{type}"

  setContent: (content) ->
    pos = @ace.getCursorPosition()
    @ace.setValue content, 1
    @ace.moveCursorToPosition(pos)

  saveFile: ->
    content = @ace.getValue()
    editor = @

    old = $(".stage-floater")

    $stage = $ "<iframe/>",
      "class": "stage"
      frameborder: 0
      allowTransparency: "true"

    $floater = $ "<div/>",
      "class": "stage-floater"

    $floater.append $stage
    $("#stage-wrapper").prepend $floater

    oldScrollTop = old.find("iframe").contents().find('body').scrollTop();

    doc = $stage.contents().get(0)
    doc.open()
    doc.write(content)
    doc.close()

    setup = ->
      throttle = (fn) ->
        _.debounce fn, 500

      win = $stage.get(0).contentWindow or $stage.get(0).contentDocument?.defaultView

      try
        set = win.$(doc).find('body')
      catch e
        set = length: 0
      return false if set.length==0
      invocations = 0

      set.css("min-height", "1000px").scrollTop(oldScrollTop);
      setInterval ->
        set.css("min-height", "")
      , 200

      set.on 'cmx:updated', throttle ->
        updateControls()
        invocations++
        return if invocations==1
        console.log "update code"

        chunks = []
        win.$(doc).find("scene").each ->
          $scene = win.$ @

          model = $scene.data('cmx-model')
          model.serialize()

          html = $('<div>').append($scene.clone()).html();
          chunks.push html

        content = editor.ace.getValue()
        patched = content.replace /<scene(.|[\r\n])+?\/scene>/mg, -> chunks.shift()

        editor.setContent patched

      return true

    interval = setInterval ->
      clearInterval interval if setup()
    , 50

    setTimeout ->
      old.fadeOut 300, ->
        $(@).remove()
    , 200

$ ->
  Modernizr.Detectizr.detect();
  env = Modernizr.Detectizr.device
  if env.browserEngine == "webkit" or $.cookie("letmein")
    $(".supported").css("display", "block")
  else
    $("#pass-button").on "click", ->
      $.cookie("letmein", "now!", expires:30)
      window.location.reload()

    $(".unsupported").css("display", "block")
    return

  if env.os == "mac"
    $('#apply').append(" (CMD+S)")
  else
    $('#apply').append(" (CTRL+S)")

  initializeHelp()
  initializeUndoRedo()
  updateControls()

  console.log "editor started"
  editor = new Editor()
  window.cmxEditor = editor

  src = getParameterByName("src")

  hash = "?"
  if not src
    hash = window.location.hash.substring(1)
    if hash
      src = getGistUrl(hash)
    else
      src = window.location.href+"sample.html"

  $(document).ajaxError (event, args...) ->
    $(".supported").css("display", "none")
    $(".error").css("display", "block")
    $('#error-response').text(args[0].responseText)
    $('#error-gist-number').text('#'+hash)
    $('#error-gist-link').attr('href', src).text(src)
    $('#error-gist-index-link').attr('href', "https://gist.github.com/#{hash}")

    console.log "failed to fetch content", args

  console.log "fetching #{src}..."
  $.get src, (content) ->
    console.log "got", content
    target = src
    if typeof content == "object"
      target = content.html_url
      content = content.files?["index.html"]?.content

    $('#targetFile').attr('href', target).text(target)

    editor.setContent content
    editor.saveFile()
    console.log "editor ready"
    $('#desk').css('display', 'block')
