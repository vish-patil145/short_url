# app/controllers/redirects_controller.rb
class RedirectsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    campaign = Campaign.find_by!(slug: params[:slug])

    unless campaign.active?
      return render json: { error: "This campaign link has expired or hasn't started yet" }, status: :gone
    end

    campaign.increment!(:clicks_count)
    redirect_to campaign.original_url, allow_other_host: true, status: :moved_permanently
  end

  private

  def not_found
    render json: { error: "Campaign not found" }, status: :not_found
  end
end