class Responder < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :emergency, foreign_key: :emergency_code, primary_key: :code

  validates :capacity, presence: true, inclusion: { in: 1..5 }
  validates :name, presence: true, uniqueness: true
  validates :type, presence: true

  def capacity_matches_emergency_severity?
    Responder.capacity_matches_emergency_severity?(emergency, self)
  end

  def self.filter_by_capacity(responders, emergency_severity_value)
    return [] if responders.nil?
    responders.select { |responder| responder['capacity'] == emergency_severity_value }
  end

  def dispatch(emergency_code)
    update_attributes(emergency_code: emergency_code) 
  end

  def self.capacity_matches_emergency_severity?(emergency, responder)
    emergency_severity = "#{responder.type.downcase.to_sym}_severity"
    emergency[emergency_severity] == responder.capacity
  end

  def self.available_on_duty_for_emergency_severity(emergency_severity_type, emergency_severity_value = nil)
    available_on_duty = where(emergency_code: nil, type: emergency_severity_type.titlecase, on_duty: true).order(capacity: :desc)

    if emergency_severity_value.present?
      available_on_duty.each do |responder|
        (available_on_duty_capacity_matching_emergency_severity ||= []) << responder if emergency_severity_severity_value == responder.capacity
      end

      return available_on_duty_capacity_matching_emergency_severity
    end

    available_on_duty || []
  end

  def self.capacities
    capacities = {}
    Responder.select('type').each do |responder|
      capacities[responder.type] = type_capacities(responder.type)
    end

    capacities
  end

  def self.available(type)
    Responder.where(type: type).reduce([]) do |responders, responder|
      responders << responder.capacity if responder.emergency.try(:resolved_at).present? || responder.emergency_code.nil?
      responders
    end
  end

  def self.available_on_duty(type)
    Responder.where(type: type).reduce([]) do |responders, responder|
      responders << responder.capacity if (responder.emergency.try(:resolved_at).present? || responder.emergency_code.nil?) && responder.on_duty == true
      responders
    end
  end

  def self.type_capacities(type)
    all = Responder.select('capacity').where(type: type).map(&:capacity).sum
    available = available(type).sum
    on_duty = Responder.select('capacity').where(type: type, on_duty: true).map(&:capacity).sum
    available_on_duty = available_on_duty(type).sum

    [all, available, on_duty, available_on_duty]
  end
end
