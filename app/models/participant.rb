class Participant < ApplicationRecord
  belongs_to :person
  belongs_to :activity
end
