# discuss comments may reference comments with disqus url
# redirect /gist/123456 -> /#123456
m = location.pathname.match /^\/gist\/([^#?\/]+)/
window.location = "/##{m[1]}" if m