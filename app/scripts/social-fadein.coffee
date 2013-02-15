$ ->
  fn = ->
    $(".bs-docs-social-buttons").css("opacity", 0).css("display", "block").animate opacity: 1

  setTimeout fn, 2000
