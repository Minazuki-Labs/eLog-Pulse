class StockOrder < ApplicationRecord
  belongs_to :user                                        # Person who ordered it
  belongs_to :school, class_name: "User"                  # School the order is for
  belongs_to :manager, class_name: "User", optional: true # Manager that ordered it

  belongs_to :approver_1, class_name: "User", optional: true
  belongs_to :approver_2, class_name: "User", optional: true

  has_many :stock_order_items, dependent: :destroy
  has_many :stock_sub_items, through: :stock_order_items
  accepts_nested_attributes_for :stock_order_items, allow_destroy: true, reject_if: :all_blank

  has_one_attached :order_proof # File upload for order proof

  enum :status, { pending: 0, rejected: 1, in_delivery: 2, completed: 3 }, validate: true

  validates :company_name, presence: true
  validates :teacher_phone_number, presence: true
  validates :teacher_email, presence: true
  validates :approver_1_id, presence: true
  validates :status, presence: true
  validates :stock_order_items, presence: true

  validates :order_proof, presence: true, if: -> { in_delivery? || completed? }

  scope :accessible_by, ->(user) {
    where(user_id: user.id)
      .or(where(manager_id: user.id))
      .or(where(approver_1_id: user.id))
      .or(where(approver_2_id: user.id))
  }
end
