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

  describe "content structure validation" do
    context "with Delivery form type" do
      let(:form) { Form.new(valid_attributes) }

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when missing destination" do
        form.content = form.content.except("destination")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: destination")
      end

      it "is invalid when missing start_time" do
        form.content = form.content.except("start_time")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: start_time")
      end

      it "is invalid when missing items" do
        form.content = form.content.except("items")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: items")
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
            last_inspection_date: Time.now,
            notes: "Everything looks good"
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when missing mileage" do
        form.content = form.content.except("mileage")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: mileage")
      end

      it "is invalid when missing last_inspection_date" do
        form.content = form.content.except("last_inspection_date")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: last_inspection_date")
      end

      it "is invalid when missing oil_changed" do
        form.content = form.content.except("oil_changed")

        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: oil_changed")
      end
    end

    context "with Hazmat form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Hazmat",
          content: {
            shipment_id: "HAZ-123",
            hazardous_materials: [ "Flammable liquid", "Corrosive substance" ],
            inspection_passed: true
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when missing required fields" do
        form.content = form.content.except("inspection_passed")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: inspection_passed")
      end
    end

    context "with Pre-delivery Inspection form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Pre-delivery Inspection",
          content: {
            start_time: ""
          }
        ))
      end

      it "is valid with all required fields" do
        expect(form).to be_valid
      end

      it "is invalid when missing required fields" do
        form.content = form.content.except("start_time")
        expect(form).not_to be_valid
        expect(form.errors[:content]).to include("is missing required fields: start_time")
      end
    end

    context "with unknown form type" do
      let(:form) do
        Form.new(valid_attributes.merge(
          form_type: "Unknown",
          content: { random: "data" }
        ))
      end

      it "skips content structure validation" do
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
end
