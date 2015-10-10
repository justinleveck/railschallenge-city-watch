class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: :emergency_code, primary_key: :code

  validates :code, uniqueness: true, presence: true
  validate :severity_greater_than_or_equal_to_zero
  validates :police_severity, presence: true, numericality: true
  validates :fire_severity, presence: true, numericality: true
  validates :medical_severity, presence: true, numericality: true

  after_save :dispatch

  def as_json
    { 'emergency' => super.except('id', 'updated_at', 'created_at') }
  end

  def self.full_responses
    count = 0

    Emergency.with_responders.map do |emergency|
      count += 1 if emergency.all_responder_capacities_match_emergency_severities?
    end

    [count, Emergency.all.count] 
  end

  def severities
    { 'police' => police_severity, 'fire' => fire_severity, 'medical' => medical_severity }
  end

  def all_responder_capacities_match_emergency_severities?
    responders.each do |responder|
      return false if !responder.capacity_matches_emergency_severity?
    end

    true
  end

  def self.with_responders
    Emergency.includes(:responders).where.not(responders: { emergency_code: nil })
  end

  private

  def dispatch
    severities.each do |severity_type, severity_value|
      available_responders = Responder.available_on_duty_for_emergency_severity(severity_type)
      capable_responders = Responder.filter_by_capacity(available_responders, severity_value)
      responder_dispatched = capable_responders.first.try(:dispatch, code)

      unless responder_dispatched
        available_responders.each do |available_responder|
          available_responder.dispatch(code) if severity_value > 0
          severity_value -= available_responder.capacity
        end
      end
    end
  end

  def severity_greater_than_or_equal_to_zero
    severities = attribute_names.keep_if { |n| n if n.include?('severity') }

    severities.each do |severity|
      errors.add(severity.to_sym, 'must be greater than or equal to 0') if self[severity].to_i < 0
    end
  end
end
