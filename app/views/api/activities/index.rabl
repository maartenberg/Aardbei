collection @activities

attributes :id, :name, :description, :location, :start, :end, :deadline

node :no_response_action do |a|
  {
    true => "present",
    false => "absent"
  }[a.no_response_action]
end
