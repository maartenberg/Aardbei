// Provides handlers for the buttons!

document.addEventListener("turbolinks:load", setup_handlers);

// Add the presence handler to all buttons on the page
function setup_handlers()
{
  $('.btn-presence').on("click", change_presence);
  $('.editable').editable();
}

// Callback that is triggered when a presence button is clicked.
// Creates an AJAX-request and registers the appropriate handlers once it is done.
function change_presence(e)
{
	// Gather data
	var group, person, activity, state;
	group 	 = this.dataset["groupId"];
	person   = this.dataset["personId"];
	activity = this.dataset["activityId"];
	rstate 	 = this.dataset["newState"];

	var state;
	switch (rstate)
	{
		case "present":
			state = true;
			break;

		case "absent":
			state = false;
			break;

		case "unknown":
			state = null;
			break;
	}

	// Make request
	var req;
	req = $.ajax(`/groups/${group}/activities/${activity}/presence`,
		{
		  method: 'PUT',
		  data: {person_id: person, attending: state}
		}
	)
	.done( activity_changed )
	.fail( alert_failure );

	// Pack data for success
	req.aardbei_activity_data =
		{
			group: group,
			person: person,
			activity: activity,
			state: state
		};
}

// Update all references on the page to this activity:
// 1. The activity's row-color in any tables
// 2. The present/absent buttons
function activity_changed(data, textStatus, xhr)
{
	// Unpack activity-data
	var target;
	target = xhr.aardbei_activity_data;

	// Determine what color and icons we're going to use
	var new_rowclass;
	var new_confirm_icon, new_decline_icon;
	switch (target.state)
	{
		case true:
			new_rowclass = "success";
			new_confirm_icon = check_selected;
			new_decline_icon = times_unselected;
			break;

		case false:
			new_rowclass = "danger";
			new_confirm_icon = check_unselected;
			new_decline_icon = times_selected;
			break;

		case null:
			new_rowclass = "warning";
			new_confirm_icon = check_unselected;
			new_decline_icon = times_unselected;
			break;
	}

	// Update all tr's containing this person's presence
	$(`tr[data-person-id=${target.person}][data-activity-id=${target.activity}]`)
	  .removeClass('success danger warning')
	  .addClass(new_rowclass);

	// Update all buttons for this person's presence
    $(`.btn-present[data-person-id=${target.person}][data-activity-id=${target.activity}]`)
      .html(new_confirm_icon);
    $(`.btn-absent[data-person-id=${target.person}][data-activity-id=${target.activity}]`)
      .html(new_decline_icon);

    // Add text to all 'wide' buttons
    $(`.btn-present[data-person-id=${target.person}][data-activity-id=${target.activity}][data-wide=1]`)
      .append(" Present");
    $(`.btn-absent[data-person-id=${target.person}][data-activity-id=${target.activity}][data-wide=1]`)
      .append(" Absent");
}

function alert_failure(data, textStatus, xhr)
{
	alert(`Something broke! We got a ${textStatus}, (${data}).`);
}

var check_unselected = '<i class="fa fa-check"></i>';
var check_selected = '<i class="fa fa-check-circle"></i>';
var times_unselected = '<i class="fa fa-times"></i>';
var times_selected = '<i class="fa fa-times-circle"></i>';
