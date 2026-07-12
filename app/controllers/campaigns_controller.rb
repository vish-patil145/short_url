# app/controllers/campaigns_controller.rb
class CampaignsController < ApplicationController
  def create
    campaign = Campaign.new(campaign_params)

    if campaign.save
      render json: campaign_response(campaign), status: :created
    else
      render json: { errors: campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    campaigns = Campaign.all.order(created_at: :desc)
    render json: campaigns.map { |c| campaign_response(c) }
  end

  private

  def campaign_params
    params.permit(:name, :slug, :original_url, :campaign_type, :starts_at, :ends_at)
  end

  def campaign_response(campaign)
    {
      name: campaign.name,
      slug: campaign.slug,
      short_url: "#{request.base_url}/#{campaign.slug}",
      original_url: campaign.original_url,
      campaign_type: campaign.campaign_type,
      active: campaign.active?,
      starts_at: campaign.starts_at,
      ends_at: campaign.ends_at,
      clicks_count: campaign.clicks_count
    }
  end
end