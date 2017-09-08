object @group

attributes :id, :name

child :members do
  child :person do
    attribute :id, :full_name
  end
  attribute :is_leader
end

child :activities do
  attributes :id, :name
end