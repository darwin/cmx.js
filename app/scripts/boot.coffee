$ ->

  hash = window.location.hash.substring(1)
  unless hash
    $("#homepage").css "display", "block"
    return

  src = "https://api.github.com/gists/" + hash
  $(document).ajaxError (event, xhr) ->
    $("#error").css "display", "block"
    $("#error-response").text xhr.responseText
    $("#error-gist-number").text "#" + hash
    $("#error-gist-link").attr("href", src).text src
    $("#error-gist-index-link").attr "href", "https://gist.github.com/" + hash
    console.log "failed to fetch the content"

  console.log "fetching #{src}..."
  $.get src, (content) ->
    if typeof content == "object"
      content = content.files?["index.html"]?.content
    console.log content
    $stage = $("<iframe/>",
      class: "stage"
      frameborder: 0
      allowTransparency: "true"
    )
    $("#comix").append $stage
    doc = $stage.contents().get(0)
    doc.open()
    doc.write content
    doc.close()
    $("#comix").css "display", "block"
