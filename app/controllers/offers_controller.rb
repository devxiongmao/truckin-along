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
    @offers = []
    errors = []

    offer_params = bulk_offer_params
    if offer_params.empty?
      redirect_to offers_path, alert: "No offers provided"
      return
    end

    offer_params.each_with_index do |offer_attrs, index|
      offer = Offer.new(offer_attrs)
      offer.status = "issued"
      authorize offer
      @offers << offer

      unless offer.valid?
        errors << "Offer #{index + 1}: #{offer.errors.full_messages.join(', ')}"
      end
    end

    if errors.empty?
      Offer.transaction do
        @offers.each(&:save!)
      end
      redirect_to offers_path, notice: "#{@offers.count} offers were successfully created."
    else
      redirect_to offers_path, alert: "Errors occurred: #{errors.join('; ')}"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to offers_path, alert: "There was an error creating the offers: #{e.message}"
  end

  private

  def bulk_offer_params
    offers_param = params[:offers]
    return [] if offers_param.blank?

    # Convert hash with numeric keys to array of permitted parameters
    offers_param.values.map do |offer|
      offer.permit(
        :shipment_id,
        :company_id,
        :reception_address,
        :pickup_from_sender,
        :deliver_to_door,
        :dropoff_location,
        :pickup_at_dropoff,
        :price,
        :notes,
      )
    end
  end
end
