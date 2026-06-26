class Location < ApplicationRecord
  belongs_to :school, class_name: "User"

  has_many :equipment, dependent: :destroy
  has_many :tickets

  accepts_nested_attributes_for :equipment, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :school_id }

  validate :owner_must_be_a_school

  private

  def owner_must_be_a_school
    return unless school
    errors.add(:school, "must have the 'school' role") unless school.school?
  end
end
