require 'rails_helper'

# Create a test model to use with the validator
class TestModel
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :json_data
  validates :json_data, json: true
end

# Create a test model with custom error message
class TestModelWithMessage
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :json_data
  validates :json_data, json: { message: "must be valid JSON format" }
end

RSpec.describe JsonValidator do
  let(:model) { TestModel.new }
  let(:model_with_message) { TestModelWithMessage.new }

  context "when value is nil" do
    it "is valid" do
      model.json_data = nil
      expect(model).to be_valid
    end
  end

  context "when value is already a Hash" do
    it "is valid" do
      model.json_data = { "key" => "value" }
      expect(model).to be_valid
    end
  end

  context "when value is already an Array" do
    it "is valid" do
      model.json_data = [ "item1", "item2" ]
      expect(model).to be_valid
    end
  end

  context "when value is a valid JSON string" do
    it "is valid with object JSON" do
      model.json_data = '{"key": "value"}'
      expect(model).to be_valid
    end

    it "is valid with array JSON" do
      model.json_data = '["item1", "item2"]'
      expect(model).to be_valid
    end

    it "is valid with nested JSON" do
      model.json_data = '{"key": {"nested": "value"}, "array": [1, 2, 3]}'
      expect(model).to be_valid
    end

    it "is valid with numeric JSON" do
      model.json_data = '123'
      expect(model).to be_valid
    end

    it "is valid with boolean JSON" do
      model.json_data = 'true'
      expect(model).to be_valid
    end
  end

  context "when value is invalid JSON" do
    it "is invalid with malformed JSON" do
      model.json_data = '{"key": "value"'
      expect(model).not_to be_valid
      expect(model.errors[:json_data]).to include("is not valid JSON")
    end

    it "is invalid with incorrect syntax" do
      model.json_data = '{key: value}'
      expect(model).not_to be_valid
    end

    it "uses custom error message when provided" do
      model_with_message.json_data = 'invalid json'
      expect(model_with_message).not_to be_valid
      expect(model_with_message.errors[:json_data]).to include("must be valid JSON format")
    end
  end

  context "when value responds to to_s but isn't a string" do
    it "tries to parse the string representation" do
      # Using a custom object with a to_s method that returns valid JSON
      custom_object = double("CustomObject", to_s: '{"key": "value"}')
      model.json_data = custom_object
      expect(model).to be_valid

      # Using a custom object with a to_s method that returns invalid JSON
      invalid_object = double("InvalidObject", to_s: '{"key": }')
      model.json_data = invalid_object
      expect(model).not_to be_valid
    end
  end
end
