class StockOrder < ApplicationRecord
  belongs_to :user                                            # Person who ordered it
  belongs_to :school, class_name: "User"                      # School the order is for
  belongs_to :contractor, class_name: "User", optional: true  # Contractor assigned to order
  belongs_to :company, optional: true

  belongs_to :approver_1, class_name: "User", optional: true
  belongs_to :approver_2, class_name: "User", optional: true

  has_many :stock_order_items, dependent: :destroy
  has_many :stock_sub_items, through: :stock_order_items
  accepts_nested_attributes_for :stock_order_items, allow_destroy: true, reject_if: :all_blank

  has_one_attached :order_proof # File upload for order proof

  enum :status, { pending: 0, rejected: 1, in_delivery: 2, completed: 3 }, validate: true

  validates :company_id, presence: true, unless: -> { pending? && approver_2_id.blank? && contractor_id.blank? }
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

  after_create :send_creation_and_first_approval_emails
  after_update :check_status_and_assignment_changes

  scope :accessible_by, ->(user) {
    if user.admin? && !user.contractor? && !user.manager?
      all
    elsif user.contractor? || user.manager?
      where(
        "stock_orders.user_id = ? OR " \
        "(stock_orders.status = ? AND (" \
          "stock_orders.contractor_id = ? OR " \
          "(stock_orders.approver_1_id = ? AND stock_orders.approver_2_id IS NULL AND stock_orders.contractor_id IS NULL) OR " \
          "(stock_orders.approver_2_id = ? AND stock_orders.contractor_id IS NULL)" \
        "))",
        user.id, StockOrder.statuses[:pending], user.id, user.id, user.id
      )
    else
      where(user_id: user.id)
    end
  }

  def active_id
    contractor_id.presence || approver_2_id.presence || approver_1_id
  end

  def can_modify_items?(user)
    return true if user.admin?

    current_order = errors.any? ? self.class.find(id) : self
    return false if current_order.contractor_id.present?

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

    if contractor_id.present? && contractor_id == approver_2_id
      errors.add(:contractor_id, "cannot be the same as the second approver")
    end
  end

  def auto_set_in_delivery_status
    if order_proof.attached? && pending?
      self.status = :in_delivery
    end
  end

  def send_creation_and_first_approval_emails
    StockOrderMailer.order_created(self).deliver_later

    if approver_1.present?
      StockOrderMailer.approval_required(self, approver_1).deliver_later
    end
  end

  def check_status_and_assignment_changes
    if saved_change_to_approver_2_id? && approver_2.present?
      StockOrderMailer.approval_required(self, approver_2).deliver_later
    end

    if saved_change_to_contractor_id? && contractor.present? && pending?
      StockOrderMailer.approval_required(self, contractor).deliver_later
    end

    if saved_change_to_status? && in_delivery?
      StockOrderMailer.order_in_delivery(self).deliver_later
    end

    if saved_change_to_status? && completed? && contractor.present?
      StockOrderMailer.order_completed(self).deliver_later
    end
  end
end
