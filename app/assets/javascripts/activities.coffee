$(document).on 'turbolinks:load', ->
  clipboard = new Clipboard('.copy-reactions', {
    'text': clipreactions
  })
  $('.subgroup-filter').on('change', (e) -> filterparticipants(e))

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

@filterparticipants = (e) ->
  show = e.target.value
  if (show != 'all')
	  selector = "[data-subgroup-id=" + e.target.value + "]"
	  $('.participant-row').hide()
	  $(selector).show()
  else
    $('.participant-row').show()

@updatecounts = (subgroupid) ->
  selector = 'tr.participant-row'
  if (subgroupid)
    selector = 'tr.participant-row[data-subgroup-id=' + subgroupid + ']'
