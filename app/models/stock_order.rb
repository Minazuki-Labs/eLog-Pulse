class StockOrder < ApplicationRecord
  belongs_to :user                                        # Person who ordered it
  belongs_to :school, class_name: "User"                  # School the order is for
  belongs_to :manager, class_name: "User", optional: true # Manager that ordered it
  belongs_to :company, optional: true

  belongs_to :approver_1, class_name: "User", optional: true
  belongs_to :approver_2, class_name: "User", optional: true

  has_many :stock_order_items, dependent: :destroy
  has_many :stock_sub_items, through: :stock_order_items
  accepts_nested_attributes_for :stock_order_items, allow_destroy: true, reject_if: :all_blank

  has_one_attached :order_proof # File upload for order proof

  enum :status, { pending: 0, rejected: 1, in_delivery: 2, completed: 3 }, validate: true

  validates :company_id, presence: true, unless: -> { pending? && approver_2_id.blank? && manager_id.blank? }
  validates :school_id, presence: true
  validates :user_id, presence: true
  validates :teacher_phone_number, presence: true
  validates :teacher_email, presence: true
  validates :approver_1_id, presence: true
  validates :status, presence: true
  validates :stock_order_items, presence: true

  validates :order_proof, presence: true, if: -> { in_delivery? || completed? }
  validate :prevent_self_approval_or_duplicate, on: [ :create, :update ]

  before_save :auto_set_in_delivery_status

  scope :accessible_by, ->(user) {
    if user.admin?
      all
    else
      where(user_id: user.id)
        .or(where(manager_id: user.id))
        .or(where(approver_1_id: user.id))
        .or(where(approver_2_id: user.id))
    end
  }

  def active_manager_id
    manager_id.presence || approver_2_id.presence || approver_1_id
  end

  def can_modify_items?(user)
    return true if user.admin?

    current_order = errors.any? ? self.class.find(id) : self
    return false if current_order.manager_id.present?

    if current_order.approver_2_id.present?
      current_order.approver_2_id == user.id
    else
      current_order.approver_1_id == user.id
    end
  end

  private

  def prevent_self_approval_or_duplicate
    if approver_2_id.present? && (approver_2_id == user_id || approver_2_id == approver_1_id)
      errors.add(:approver_2_id, "cannot be the same as the requester or first approver")
    end

    if manager_id.present? && manager_id == approver_2_id
      errors.add(:manager_id, "cannot be the same as the second approver")
    end
  end

  def auto_set_in_delivery_status
    if order_proof.attached? && pending?
      self.status = :in_delivery
    end
  end
end
