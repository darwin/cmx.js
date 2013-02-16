# discuss comments may reference comments with disqus url
# redirect /gist/123456 -> /#123456
m = location.pathname.match /^\/gist\/([^#?\/]+)/
if m
  window.location = "/##{m[1]}"
  return

# GA links may reference error pages
# redirect /error/123456 -> /#123456
m = location.pathname.match /^\/error\/([^#?\/]+)/
if m
  window.location = "/##{m[1]}"
  return

# no redirect, display 404 content
document.getElementById("body").style.display = "block"