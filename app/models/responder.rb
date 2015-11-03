class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :emergency, foreign_key: :emergency_code, primary_key: :code

  validates :capacity, presence: true, inclusion: { in: 1..5 }
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true

  scope :type_available_on_duty, ->(type) { 
    where(
      emergency_code: nil, 
      type: type.titlecase, 
      on_duty: true).order(capacity: :desc)
  }

  scope :with_capacity, ->(capacity) { where(capacity: capacity) }

  scope :type_available_on_duty_capacity, ->(type) {
    joins("LEFT JOIN `emergencies` ON responders.emergency_code = emergencies.code")
    .where("responders.type = ?", type)
    .where("responders.on_duty='t'")
    .where("responders.emergency_code IS NULL OR emergencies.resolved_at IS NOT NULL")
  }

  scope :type_available, ->(type) {
    joins("LEFT JOIN `emergencies` ON responders.emergency_code = emergencies.code")
    .where("responders.type = ?", type)
    .where("emergencies.resolved_at IS NOT NULL OR responders.emergency_code IS NULL")
  }

  def capacity_matches_emergency_severity?
    Responder.capacity_matches_emergency_severity?(emergency, self)
  end

  def dispatch(emergency_code)
    update_attributes(emergency_code: emergency_code) 
  end

  def self.capacity_matches_emergency_severity?(emergency, responder)
    emergency_severity = "#{responder.type.downcase.to_sym}_severity"
    emergency[emergency_severity] == responder.capacity
  end

  def self.capacities
    capacities = {}
    Responder.select('type').each do |responder|
      capacities[responder.type] = type_capacities(responder.type)
    end

    capacities
  end

  def self.all_capacity_total(type)
    Responder.select('capacity').where(type: type).map(&:capacity).sum
  end

  def self.available_capacity_total(type)
    type_available(type).map(&:capacity).sum
  end

  def self.on_duty_capacity_total(type)
    Responder.select('capacity').where(type: type, on_duty: true).map(&:capacity).sum
  end

  def self.available_on_duty_capacity_total(type)
    type_available_on_duty_capacity(type).map(&:capacity).sum 
  end

  def self.type_capacities(type)
    all = all_capacity_total(type)
    available = available_capacity_total(type)
    on_duty = on_duty_capacity_total(type)
    available_on_duty = available_on_duty_capacity_total(type)

    [all, available, on_duty, available_on_duty]
  end
end
