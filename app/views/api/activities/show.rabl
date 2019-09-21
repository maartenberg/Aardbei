object @activity

attributes :id, :name, :description, :location, :start, :end, :deadline, :reminder_at

node :no_response_action do |a|
  {
    true => "present",
    false => "absent"
  }[a.no_response_action]
end

node :response_counts do
  c = @activity.state_counts
  {
    "present": c[true]  || 0,
    "unknown": c[nil]   || 0,
    "absent": c[false] || 0
  }
end

child :participants do
  child :person do
    attribute :id, :full_name
  end

  child :member do
    attribute :id, :display_name, :is_leader
    child :person do
      attribute :id, :full_name
    end
  end

  attribute :attending, :notes, :is_organizer, :id
end

child :group do
  attribute :id, :name
end
