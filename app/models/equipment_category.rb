class EquipmentCategory < ApplicationRecord
  has_many :equipment, dependent: :destroy
  has_many :issue_types, dependent: :destroy
  has_many :location_template_items

  accepts_nested_attributes_for :issue_types, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validate :prevent_manual_other_issue_type
  validate :at_least_one_custom_issue

  before_validation :ensure_other_issue_type

  private

  def at_least_one_custom_issue
    custom_issues = issue_types.reject do |i|
      i.marked_for_destruction? ||
        i.name.blank? ||
        i.name.to_s.strip.casecmp(IssueType::OTHER_NAME).zero?
    end

    if custom_issues.empty?
      errors.add(:base, "At least one equipment issue must be provided.")
    end
  end

  def prevent_manual_other_issue_type
    other_count = issue_types.count { |i| !i.marked_for_destruction? && i.name.to_s.strip.casecmp(IssueType::OTHER_NAME).zero? }
    if other_count > 1
      errors.add(:base, "The 'Other' issue is added automatically and cannot be entered manually.")
    end
  end

  def ensure_other_issue_type
    other_exists = issue_types.any? { |i| !i.marked_for_destruction? && i.name.to_s.strip.casecmp(IssueType::OTHER_NAME).zero? }
    unless other_exists
      issue_types.build(name: IssueType::OTHER_NAME)
    end
  end
end
