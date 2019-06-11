$(document).on 'turbolinks:load', ->
  x = 1

@getSheets = ->
  $('link[rel$=stylesheet][title]')

@listSheetNames = ->
  for sheet in getSheets()
    sheet.title

@activateSheet = (sheetName) ->
  $('link[rel$=stylesheet][title="'+sheetName+'"]').prop('disabled', false)
  $('link[rel$=stylesheet][title!="'+sheetName+'"]').prop('disabled', true)