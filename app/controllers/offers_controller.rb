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
      # Send notification emails to shipment owners
      @offers.each do |offer|
        OfferMailer.offer_received(offer.id).deliver_later
      end
      redirect_to offers_path, notice: "#{@offers.count} offers were successfully created."
    else
      redirect_to offers_path, alert: "Errors occurred: #{errors.join('; ')}"
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to offers_path, alert: "There was an error creating the offers: #{e.message}"
  end

  def accept
    @offer = Offer.find(params[:id])

    if @offer.issued?
      authorize @offer, :accept?

      Offer.transaction do
        @offer.update!(status: :accepted)

        preference = @offer.company.shipment_action_preferences.find_by(action: "claimed_by_company")
        if preference
          @offer.shipment.update!(
            company_id: @offer.company_id,
            shipment_status_id: preference.shipment_status_id)
        else
          @offer.shipment.update!(company_id: @offer.company_id)
        end

        DeliveryShipment.create!(
          shipment: @offer.shipment,
          sender_address: @offer.reception_address,
          receiver_address: @offer.dropoff_location
        )

        # Reject all other issued offers for the same shipment
        Offer.joins(:shipment)
             .where(shipment_id: @offer.shipment_id, status: :issued)
             .where.not(id: @offer.id)
             .update_all(status: :rejected)
      end
      # Notify company admins that their offer was accepted
      OfferMailer.offer_accepted(@offer.id).deliver_later
      redirect_to offers_path, notice: "Offer was successfully accepted. All other offers for this shipment have been rejected."
    else
      redirect_to offers_path, alert: "Only issued offers can be accepted."
    end
  end

  def reject
    @offer = Offer.find(params[:id])

    if @offer.issued?
      authorize @offer, :reject?
      @offer.update!(status: :rejected)
      # Notify company admins that their offer was rejected
      OfferMailer.offer_rejected(@offer.id).deliver_later
      redirect_to offers_path, notice: "Offer was successfully rejected."
    else
      redirect_to offers_path, alert: "Only issued offers can be rejected."
    end
  end

  def withdraw
    @offer = Offer.for_company(current_company).find(params[:id])

    if @offer.issued?
      authorize @offer, :withdraw?
      @offer.update!(status: :withdrawn)
      redirect_to offers_path, notice: "Offer was successfully withdrawn."
    else
      redirect_to offers_path, alert: "Only issued offers can be withdrawn."
    end
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
