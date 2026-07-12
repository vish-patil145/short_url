# app/models/campaign.rb
class Campaign < ApplicationRecord
  enum :campaign_type, { weekday: 0, festival: 1, custom: 2 }

  validates :name, presence: true
  validates :original_url, presence: true,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create

  scope :active_now, -> { where("(starts_at IS NULL OR starts_at <= ?) AND (ends_at IS NULL OR ends_at >= ?)", Time.current, Time.current) }

  def active?
    (starts_at.nil? || starts_at <= Time.current) &&
      (ends_at.nil? || ends_at >= Time.current)
  end

  private

  # e.g. "Sunday Bonanza" -> "sunday-bonanza", "sunday-bonanza-2" if taken
  def generate_slug
    return if slug.present?

    base = name.to_s.parameterize
    candidate = base
    counter = 2

    while Campaign.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end