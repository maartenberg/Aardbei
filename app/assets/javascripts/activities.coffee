$(document).on 'turbolinks:load', ->
  clipboard = new Clipboard('.copy-reactions', {
    'text': clipreactions
  })

@clipreactions = (trigger) ->
  id = trigger.dataset['activity']
  dopresent = (typeof trigger.dataset['present'] != 'undefined')
  doabsent  = (typeof trigger.dataset['absent']  != 'undefined')
  donoresp  = (typeof trigger.dataset['unknown'] != 'undefined')
  req = $.ajax({
    async: false,
    method: 'GET',
    url: '/api/activities/' + id + '/response_summary'
  })
  resp = req.responseJSON.response_summary

  res = []
  if dopresent
    res.push(resp['present']['message'])
  if doabsent
    res.push(resp['absent']['message'])
  if donoresp
    res.push(resp['unknown']['message'])

  res.join('\n')
