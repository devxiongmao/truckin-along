class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @rating = current_user.ratings.build(rating_params)
    authorize @rating

    shipment = @rating.delivery_shipment&.shipment

    if @rating.save
      redirect_to shipment_path(shipment), notice: "Rating was successfully submitted! Thank you."
    else
      redirect_to shipment_path(shipment), alert: "Something went wrong, please try again."
    end
  end

  private

    def rating_params
      params.require(:rating).permit(:comment, :stars, :company_id, :delivery_shipment_id)
    end
end
