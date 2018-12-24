object @activity

attributes :id, :name, :start, :end, :deadline, :location, :reminder_at

node :response_counts do
  c = @activity.state_counts
  {
    "present": c[true]  || "0",
    "unknown": c[nil]   || "0",
    "absent": c[false] || "0"
  }
end

child :participants do
  child :person do
    attribute :id, :full_name
  end
  attribute :attending, :notes, :is_organizer
end

child :group do
  attribute :id, :name
end
