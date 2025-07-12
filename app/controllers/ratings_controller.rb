class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = current_user.id
    authorize @rating

    if @rating.save
      redirect_to shipment_path(@rating.delivery_shipment.shipment), notice: "Rating was successfully submitted! Thank you."
    else
      redirect_to shipment_path(@rating.delivery_shipment.shipment), alert: "Something went wrong, please try again."
    end
  end

  private

    def rating_params
      params.require(:rating).permit(:comment, :stars, :company_id, :delivery_shipment_id)
    end
end
