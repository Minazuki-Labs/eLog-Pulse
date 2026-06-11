class OtpCode < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, length: { is: 6 }
  validates :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end
end
