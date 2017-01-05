// Provides handlers for the buttons!

$(setup_handlers);

function setup_handlers()
{
  $('.btn-present').on("click", set_present);
  $('.btn-absent').on("click", set_absent);
}

// Update all references on the page to this activity:
// 1. The present/absent buttons
// 2. The activity's row-color in any tables
function activity_changed(activity_id, new_state)
{
    // Set the present buttons and absent buttons to their appropriate state

}

function set_present(e)
{
  var group, person, activity;
  group = this.dataset["groupId"];
  person = this.dataset["personId"];
  activity = this.dataset["activityId"];
  $.ajax(`/groups/${group}/activities/${activity}/presence`,
    {
      method: 'PUT',
      data: {person_id: person, attending: true}
    }
  );

  // Set row state to success
  $(`tr[data-person-id=${person}][data-activity-id=${activity}]`)
    .removeClass('danger warning')
    .addClass('success');

  // Update present buttons
  $(`.btn-present[data-person-id=${person}][data-activity-id=${activity}]`)
    .html(check_selected);
  $(`.btn-absent[data-person-id=${person}][data-activity-id=${activity}]`)
    .html(times_unselected);
}

function set_absent()
{
  var group, person, activity;
  group = this.dataset["groupId"];
  person = this.dataset["personId"];
  activity = this.dataset["activityId"];
  $.ajax(`/groups/${group}/activities/${activity}/presence`,
    {
      method: 'PUT',
      data: {person_id: person, attending: false}
    }
  );

  // Set row state to danger
  $(`tr[data-person-id=${person}][data-activity-id=${activity}]`)
    .removeClass('success warning')
    .addClass('danger');

  // Update present buttons
  $(`.btn-present[data-person-id=${person}][data-activity-id=${activity}]`)
    .html(check_unselected);
  $(`.btn-absent[data-person-id=${person}][data-activity-id=${activity}]`)
    .html(times_selected);
}

var check_unselected = '<i class="fa fa-check"></i>';
var check_selected = '<i class="fa fa-check-circle"></i>';
var times_unselected = '<i class="fa fa-times"></i>';
var times_selected = '<i class="fa fa-times-circle"></i>';
