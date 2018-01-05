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
  if (show == 'all')
    $('.participant-row').show()
    @updatecounts()
    this.subgroupfilter = null
  else if (show == 'withoutgroup')
    selector = "tr.participant-row.success:not([data-subgroup-id])"
    $('.participant-row').hide()
    $(selector).show()
    @updatecounts()
    this.subgroupfilter = show
  else
    selector = "[data-subgroup-id=" + e.target.value + "]"
    $('.participant-row').hide()
    $(selector).show()
    @updatecounts(show)
    this.subgroupfilter = show

@updatecounts = (subgroupid) ->
  selector = 'tr.countable.participant-row'
  selectorend = '[style!="display: none;"]'

  if (subgroupid)
    selectorend = '[data-subgroup-id=' + subgroupid + ']' + selectorend

  pselect = selector + '.success' + selectorend
  uselect = selector + '.warning' + selectorend
  aselect = selector + '.danger' + selectorend

  numall = $(selector + selectorend).length
  numpresent = $(pselect).length
  numunknown = $(uselect).length
  numabsent  = $(aselect).length

  $('.state-count.all-count').html(numall)
  $('.state-count.present-count').html(numpresent)
  $('.state-count.unknown-count').html(numunknown)
  $('.state-count.absent-count').html(numabsent)
  [numpresent, numabsent, numunknown]
