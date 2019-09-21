collection @activities

attributes :id, :name, :description, :location, :start, :end, :deadline, :reminder_at

node :no_response_action do |a|
  {
    true => "present",
    false => "absent"
  }[a.no_response_action]
end

node :response_counts do |a|
  c = a.state_counts
  {
    "present": c[true]  || 0,
    "unknown": c[nil]   || 0,
    "absent": c[false] || 0
  }
end
