class Form < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :formable, polymorphic: true, optional: true

  # Common Validations
  validates :user_id, presence: true
  validates :company_id, presence: true
  validates :title, presence: true
  validates :form_type, presence: true
  validates :content, presence: true, json: true

  # Custom validation for form content structure
  validate :validate_content_structure

  scope :for_company, ->(company) { where(company_id: company.id) }

  scope :maintenance_forms, -> { where(form_type: "Maintenance") }

  # Define schema for each form type using dry-schema
  FORM_SCHEMAS = {
    "Pre-delivery Inspection" => Dry::Schema.Params do
      required(:start_time).value(:date_time)
    end,

    "Delivery" => Dry::Schema.Params do
      required(:destination).value(:string)
      required(:start_time).value(:date_time)
      required(:items).value(:array)
    end,

    "Maintenance" => Dry::Schema.Params do
      required(:mileage).value(:integer)
      required(:oil_changed).value(:bool)
      required(:tire_pressure_checked).value(:bool)
      required(:last_inspection_date).value(:date)
      required(:notes).value(:string)
    end,

    "Hazmat" => Dry::Schema.Params do
      required(:shipment_id).value(:integer)
      required(:hazardous_materials).value(:array)
      required(:inspection_passed).value(:bool)
    end
  }.freeze

  private

  def validate_content_structure
    return if content.nil? || !content.is_a?(Hash)

    schema = FORM_SCHEMAS[form_type]
    return if schema.nil?

    # Validate content against schema
    result = schema.call(content)

    # Add errors if validation failed
    unless result.success?
      result.errors.each do |error|
        errors.add(:content, "#{error.path.join('.')}: #{error.text}")
      end
    end
  end
end
