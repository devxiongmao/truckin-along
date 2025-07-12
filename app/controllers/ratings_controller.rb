class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = current_user.id
    authorize @rating

    if @rating.save
      if request.xhr?
        render json: { success: true, message: "Rating was successfully submitted! Thank you." }
      else
        redirect_to dashboard_path, notice: "Rating was successfully submitted! Thank you."
      end
    else
      if request.xhr?
        render json: { success: false, message: "Something went wrong, please try again." }, status: :unprocessable_entity
      else
        redirect_to dashboard_path, alert: "Something went wrong, please try again."
      end
    end
  end

  private

    def rating_params
      params.require(:rating).permit(:comment, :stars, :company_id, :delivery_shipment_id)
    end
end
