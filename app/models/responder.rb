class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :emergency

  validates :capacity, presence: true, inclusion: { in: 1..5 }
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
end
