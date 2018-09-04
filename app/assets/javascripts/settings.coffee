$(document).on 'turbolinks:load', ->
  clipboard = new Clipboard('.copy-url')
