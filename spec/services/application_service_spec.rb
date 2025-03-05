require 'rails_helper'

RSpec.describe ApplicationService, type: :service do
  class TestService < ApplicationService
    attr_reader :args, :ran

    def initialize(*args)
      @args = args
      @ran = false
    end

    def run
      @ran = true
      "Success"
    end
  end

  describe ".call" do
    it "initializes and runs the service" do
      result = TestService.call("arg1", "arg2")
      expect(result).to eq("Success")
    end

    it "passes arguments to the initializer" do
      service = TestService.new("arg1", "arg2")
      expect(service.args).to eq([ "arg1", "arg2" ])
    end

    it "executes the run method" do
      service = TestService.new
      expect(service.ran).to be false
      service.run
      expect(service.ran).to be true
    end
  end
end
