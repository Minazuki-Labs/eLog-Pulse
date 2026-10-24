class AppConfig < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.group_email
    find_by(key: "group_email")&.value
  end

  def self.group_email=(email)
    find_or_initialize_by(key: "group_email").update!(value: email)
  end
end
