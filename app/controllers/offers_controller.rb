class OffersController < ApplicationController
  before_action :authenticate_user!


  def index
    if current_user.customer?
      @offers = current_user.offers
    else
      @offers = Offer.for_company(current_company)
    end
  end

  def create
    @offer = Offer.new(offer_params)
    authorize @offer

    if @offer.save
      redirect_to offers_path, notice: "Offer was successfully sent."
    else
      redirect_to offers_path, alert: "There was an error creating the offer."
    end
  end
end
