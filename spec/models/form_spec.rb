require 'rails_helper'

RSpec.describe Form, type: :model do
  # Setup for tests
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:valid_attributes) do
    {
      user: user,
      company: company,
      title: "Test Form",
      form_type: "Delivery",
      content: {
        destination: "123 Main St",
        start_time: "2025-03-19T09:00:00",
        items: [ "Item 1", "Item 2" ]
      }
    }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
    it { should belong_to(:truck).optional }
    it { should belong_to(:delivery).optional }
  end

  describe "validations" do
    subject { Form.new(valid_attributes) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:company_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:form_type) }
    it { should validate_presence_of(:content) }

    it "validates that content is valid JSON" do
      form = Form.new(valid_attributes.merge(content: "invalid json"))
      expect(form).not_to be_valid
      expect(form.errors[:content]).to include("is not valid JSON")
    end
  end

  describe "content structure validation with dry-schema" do
    context "with Delivery form type" do
      let(:form) { Form.new(valid_attributes) }

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when missing destination" do
        form.content = form.content.except("destination")
        expect(form).not_to be_valid
      end

      it "is invalid when destination is not a string" do
        form.content = form.content.merge("destination" => 12345)
        expect(form).not_to be_valid
      end

      it "is invalid when start_time is not a valid datetime" do
        form.content = form.content.merge("start_time" => "not-a-date")
        expect(form).not_to be_valid
      end

      it "is invalid when items is not an array" do
        form.content = form.content.merge("items" => "not an array")
        expect(form).not_to be_valid
      end
    end

    context "with Maintenance form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Maintenance",
          content: {
            mileage: 50000,
            oil_changed: true,
            tire_pressure_checked: true,
            last_inspection_date: "2025-03-15",
            notes: "Everything looks good"
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when mileage is not an integer" do
        form.content = form.content.merge("mileage" => "fifty thousand")
        expect(form).not_to be_valid
      end

      it "is invalid when oil_changed is not a boolean" do
        form.content = form.content.merge("oil_changed" => "this be a test")
        expect(form).not_to be_valid
      end

      it "is invalid when last_inspection_date is not a valid date" do
        form.content = form.content.merge("last_inspection_date" => "not-a-date")
        expect(form).not_to be_valid
      end
    end

    context "with Hazmat form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Hazmat",
          content: {
            shipment_id: 123,
            hazardous_materials: [ "Flammable liquid", "Corrosive substance" ],
            inspection_passed: true
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when shipment_id is not an integer" do
        form.content = form.content.merge(shipment_id: "Shipment: 12345")
        expect(form).not_to be_valid
      end

      it "is invalid when hazardous_materials is not an array" do
        form.content = form.content.merge("hazardous_materials" => "Flammable liquid")
        expect(form).not_to be_valid
      end

      it "is invalid when inspection_passed is not a boolean" do
        form.content = form.content.merge("inspection_passed" => "passed")
        expect(form).not_to be_valid
      end
    end

    context "with Pre-delivery Inspection form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Pre-delivery Inspection",
          content: {
            start_time: "2025-03-19T09:00:00"
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when start_time is not a valid datetime" do
        form.content = form.content.merge("start_time" => "invalid time")
        expect(form).not_to be_valid
      end
    end

    context "with type coercion" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Maintenance",
          content: {
            mileage: "50000", # String that should be coerced to integer
            oil_changed: "true", # String that should be coerced to boolean
            tire_pressure_checked: "1", # String that should be coerced to boolean
            last_inspection_date: "2025-03-15", # String date
            notes: "Everything looks good"
          }
        ))
      end

      it "coerces values to the correct types" do
        expect(form).to be_valid
      end
    end
  end

  describe "string keys handling" do
    let(:form) do
      Form.new(valid_attributes.merge(
        content: {
          "destination" => "123 Main St",
          "start_time" => "2025-03-19T09:00:00",
          "items" => [ "Item 1", "Item 2" ]
        }
      ))
    end

    it "handles string keys in content correctly" do
      expect(form).to be_valid
    end
  end

  describe "scopes" do
    let!(:company) { create(:company) }
    let!(:other_company) { create(:company) }

    let!(:form) { create(:form, :maintenance, company: company) }
    let!(:other_form) { create(:form, :hazmat, company: other_company) }

    describe ".maintenance_forms" do
      it "includes Maintenance forms" do
        expect(Form.maintenance_forms).to include(form)
        expect(Form.maintenance_forms).not_to include(other_form)
      end
    end

    describe ".for_company" do
      it "includes forms that belong to the company" do
        expect(Form.for_company(company)).to include(form)
        expect(Form.for_company(company)).not_to include(other_form)
      end
    end
  end
end
