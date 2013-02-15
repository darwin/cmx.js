$ ->
  window.disqus_url = "http://cmx.io/"
  window.disqus_url += "##{window.gistId}" if window.gistId

  wrapper = $("<div/>").attr('id', "disqus_thread")
  if window.gistId
    $('#comix').append(wrapper)
  else
    $('.discussion').prepend(wrapper)

  dsq = document.createElement("script")
  dsq.type = "text/javascript"
  dsq.async = true
  dsq.src = "http://cmxio.disqus.com/embed.js"
  (document.getElementsByTagName("head")[0] or document.getElementsByTagName("body")[0]).appendChild dsq