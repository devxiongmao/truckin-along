require 'rails_helper'

RSpec.describe Delivery, type: :model do
  # Define a valid truck object for reuse
  let(:valid_delivery) { create(:delivery) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:truck) }
  end
end
