class Emergency < ActiveRecord::Base
  has_many :responders

  validates :code, uniqueness: true, presence: true
  validate :severity_greater_than_or_equal_to_zero
  validates :police_severity, presence: true, numericality: true
  validates :fire_severity, presence: true, numericality: true
  validates :medical_severity, presence: true, numericality: true

  def as_json
    { 'emergency' => super.except('id', 'updated_at', 'created_at') }
  end

  private

  def severity_greater_than_or_equal_to_zero
    severities = attribute_names.keep_if { |n| n if n.include?('severity') }

    severities.each do |severity|
      errors.add(severity.to_sym, 'must be greater than or equal to 0') if self[severity].to_i < 0
    end
  end
end
