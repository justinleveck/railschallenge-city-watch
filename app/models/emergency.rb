class Emergency < ActiveRecord::Base
  UNPERMITTED_PARAMS = %w(id resolved_at)

  validate :unpermitted_params?
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
    severities = self.attribute_names.keep_if { |n| n if n.include?('severity') }

    severities.each do |severity|
      errors.add(severity.to_sym, 'must be greater than or equal to 0') if self[severity].to_i < 0
    end
  end

  def unpermitted_params?
    UNPERMITTED_PARAMS.each do |unpermitted_param|
      errors.add(:base, "found unpermitted parameter: #{unpermitted_param}") if self[unpermitted_param].present?
    end
  end
end

