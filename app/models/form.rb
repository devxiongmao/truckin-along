class Form < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :truck, optional: true

  # Common Validations
  validates :user_id, presence: true
  validates :company_id, presence: true
  validates :title, presence: true
  validates :form_type, presence: true
  validates :content, presence: true, json: true

  # Custom validation for form content structure
  validate :validate_content_structure

  # Define expected fields for each form type
  FORM_TEMPLATES = {
    "Delivery" => %w[destination start_time items],
    "Maintenance" => %w[mileage oil_changed tire_pressure_checked notes],
    "Hazmat" => %w[shipment_id hazardous_materials inspection_passed]
  }.freeze

  private

  def validate_content_structure
    return if content.nil? || !content.is_a?(Hash)

    expected_keys = FORM_TEMPLATES[form_type]
    return if expected_keys.nil?

    # Convert all content keys to strings for comparison
    content_keys = content.keys.map(&:to_s)
    missing_keys = expected_keys - content_keys
    errors.add(:content, "is missing required fields: #{missing_keys.join(', ')}") if missing_keys.any?
  end
end
