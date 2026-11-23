FactoryBot.define do
  factory :ticket do
    association :school, factory: [:user, :school]
    teacher_name { "Teacher Ahmad" }
    teacher_phone_number { "0123456789" }
    teacher_email { "teacher@example.com" }
    description { "Something is broken" }
    status { :new_case }

    after(:build) do |ticket|
      ticket.location ||= create(:location, school: ticket.school)
      category = ticket.equipment&.equipment_category || create(:equipment_category)
      ticket.equipment ||= create(:equipment, location: ticket.location, equipment_category: category)
      ticket.issue_type ||= category.issue_types.find_by(name: "Default Issue") ||
                            category.issue_types.reject { |it| it.name == "Other" }.first ||
                            create(:issue_type, equipment_category: category)
    end
  end
end
