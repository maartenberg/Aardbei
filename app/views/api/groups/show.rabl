object @group

attributes :id, :name

child :members do
  attribute :id, :display_name, :is_leader
  child :person do
    attribute :id, :full_name
  end
end

child :activities do
  attributes :id, :name
end
