class OffersController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.customer?
      @offers = Offer.joins(:shipment).where(shipments: { user_id: current_user.id }, status: :issued)
    else
      @offers = Offer.for_company(current_company)
    end
  end

  def bulk_create
    offers_data = bulk_offer_params.dig(:offers_attributes)&.values

    if offers_data.blank?
      redirect_to offers_path, alert: "No offers provided" and return
    end

    @offers = []
    errors = []

    offers_data.each_with_index do |offer_attrs, index|
      offer = Offer.new(offer_attrs.merge(company_id: current_company.id, status: "issued"))

      begin
        authorize offer
        @offers << offer

        unless offer.valid?
          errors << "Offer #{index + 1}: #{offer.errors.full_messages.join(', ')}"
        end
      rescue Pundit::NotAuthorizedError
        errors << "Offer #{index + 1}: Not authorized to create this offer"
      end
    end

    if errors.empty?
      Offer.transaction { @offers.each(&:save!) }
      redirect_to offers_path, notice: "#{@offers.count} offers were successfully created."
    else
      redirect_to offers_path, alert: "Errors occurred: #{errors.join('; ')}"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to offers_path, alert: "There was an error creating the offers: #{e.message}"
  end

  private

  def bulk_offer_params
    params.fetch(:bulk_offer, {}).permit(
      offers_attributes: [
        :shipment_id,
        :reception_address,
        :pickup_from_sender,
        :deliver_to_door,
        :dropoff_location,
        :pickup_at_dropoff,
        :price,
        :notes
      ]
    )
  end
end
