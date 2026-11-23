FactoryBot.define do
  factory :ticket do
    association :school, factory: [:user, :school]
    teacher_name { "Teacher Ahmad" }
    teacher_phone_number { "0123456789" }
    teacher_email { "teacher@example.com" }
    description { "Something is broken" }
    status { :new_case }

    after(:build) do |ticket|
      if ticket.location.nil?
        ticket.school = create(:user, :school) unless ticket.school&.persisted?
        ticket.location = create(:location, school: ticket.school)
      end

      if ticket.equipment.nil?
        category = create(:equipment_category)
        ticket.equipment = create(:equipment, location: ticket.location, equipment_category: category)
      end

      if ticket.issue_type.nil?
        category = ticket.equipment.equipment_category
        ticket.issue_type = category.issue_types.find_by(name: "Default Issue") ||
                            category.issue_types.where.not(name: IssueType::OTHER_NAME).first ||
                            create(:issue_type, equipment_category: category)
      end
    end
  end
end
