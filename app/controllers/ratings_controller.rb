class RatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @rating = Rating.new(rating_params)
    @rating.user_id = current_user.id
    authorize @rating

    if @rating.save
      redirect_to dashboard_path, notice: "Rating was successfully submitted! Thank you."
    else
      redirect_to dashboard_path, alert: "Something went wrong, please try again."
    end
  end

  private

    def rating_params
      params.require(:rating).permit(:comment, :stars, :company_id)
    end
end
