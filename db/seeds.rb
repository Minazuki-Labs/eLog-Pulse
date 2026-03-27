# Run bin/rails db:seed

puts "Cleaning database"
[ Comment, Ticket, Equipment, IssueType, LocationTemplateItem, Location, LocationTemplate, EquipmentCategory, User ].each(&:delete_all)

puts "Creating users"
admin = User.create!(
  name: "Admin",
  email: "admin@test.com",
  password: "password123",
  role: :admin
)

school1 = User.create!(
  name: "SJKC Jalan Davidson",
  email: "school1@test.edu",
  password: "password123",
  role: :school
)

school2 = User.create!(
  name: "SMK (L) Methodist",
  email: "school2@test.edu",
  password: "password123",
  role: :school
)

school3 = User.create!(
  name: "SJKC Chong Wen",
  email: "school3@test.edu",
  password: "password123",
  role: :school
)

school4 = User.create!(
  name: "SJKC Chung Hwa",
  email: "school4@test.edu",
  password: "password123",
  role: :school
)

employee1 = User.create!(
  name: "Employee 1",
  email: "employee1@test.com",
  password: "password123",
  role: :employee
)

employee2 = User.create!(
  name: "Employee 2",
  email: "employee2@test.com",
  password: "password123",
  role: :employee
)

employee3 = User.create!(
  name: "Employee 3",
  email: "employee3@test.com",
  password: "password123",
  role: :employee
)

puts "Creating equipment categories and issue types"
category_issues = {
  "Projector" => [ "No Visual", "No Power", "Blurry Image" ],
  "Monitor" => [ "No Visual", "No Power", "Incorrect Colour", "Screen Flickering" ],
  "Mouse" => [ "Not Responding" ],
  "Keyboard" => [ "Not Responding" ],
  "Computer" => [ "No Power", "No Network", "Broken Port" ],
  "Scanner" => [ "No Visual", "No Power", "Blurry Image" ],
  "Smart Board" => [ "No Visual", "No Power", "Touchscreen Not Responding", "No Network", "Broken Port" ]
}

cat_records = {}

category_issues.each do |cat_name, issues|
  cat = EquipmentCategory.find_or_create_by!(name: cat_name)
  cat_records[cat_name] = cat

  # Create the specific issues for this category
  issues.each do |issue_name|
    IssueType.find_or_create_by!(
      name: issue_name,
      equipment_category: cat
    )
  end

  IssueType.find_or_create_by!(
    name: IssueType::OTHER_NAME,
    equipment_category: cat
  )
end

puts "Creating locations and assigning equipment"
class1 = Location.create!(name: "4H", school: school1)
class2 = Location.create!(name: "6K", school: school1)
office1 = Location.create!(name: "Office", school: school1)

class3 = Location.create!(name: "1E", school: school2)
class4 = Location.create!(name: "5A", school: school2)
office2 = Location.create!(name: "Office", school: school2)
lab1 = Location.create!(name: "Physics Lab", school: school2)

class5 = Location.create!(name: "3T", school: school3)
office3 = Location.create!(name: "Office", school: school3)

lab2 = Location.create!(name: "Computer Lab", school: school4)
lab3 = Location.create!(name: "Science Lab", school: school4)
office4 = Location.create!(name: "Office", school: school4)

Equipment.create!(location: class1, equipment_category: cat_records["Projector"])
Equipment.create!(location: class1, equipment_category: cat_records["Monitor"])
Equipment.create!(location: class1, equipment_category: cat_records["Mouse"])
Equipment.create!(location: class1, equipment_category: cat_records["Keyboard"])
Equipment.create!(location: class1, equipment_category: cat_records["Computer"])

Equipment.create!(location: class2, equipment_category: cat_records["Smart Board"])
Equipment.create!(location: class2, equipment_category: cat_records["Mouse"])
Equipment.create!(location: class2, equipment_category: cat_records["Keyboard"])

Equipment.create!(location: office1, equipment_category: cat_records["Computer"])
Equipment.create!(location: office1, equipment_category: cat_records["Scanner"])

Equipment.create!(location: class3, equipment_category: cat_records["Smart Board"])
Equipment.create!(location: class3, equipment_category: cat_records["Mouse"])
Equipment.create!(location: class3, equipment_category: cat_records["Keyboard"])

Equipment.create!(location: class4, equipment_category: cat_records["Smart Board"])
Equipment.create!(location: class4, equipment_category: cat_records["Mouse"])
Equipment.create!(location: class4, equipment_category: cat_records["Keyboard"])

Equipment.create!(location: office2, equipment_category: cat_records["Computer"])

Equipment.create!(location: lab1, equipment_category: cat_records["Computer"])
Equipment.create!(location: lab1, equipment_category: cat_records["Projector"])

Equipment.create!(location: class5, equipment_category: cat_records["Projector"])
Equipment.create!(location: class5, equipment_category: cat_records["Monitor"])
Equipment.create!(location: class5, equipment_category: cat_records["Mouse"])
Equipment.create!(location: class5, equipment_category: cat_records["Keyboard"])
Equipment.create!(location: class5, equipment_category: cat_records["Computer"])

Equipment.create!(location: office3, equipment_category: cat_records["Computer"])

Equipment.create!(location: lab2, equipment_category: cat_records["Computer"])
Equipment.create!(location: lab2, equipment_category: cat_records["Projector"])

Equipment.create!(location: lab3, equipment_category: cat_records["Computer"])
Equipment.create!(location: lab3, equipment_category: cat_records["Projector"])

Equipment.create!(location: office4, equipment_category: cat_records["Computer"])

puts "Creating templates"
template1 = LocationTemplate.create!(
  name: "Classroom",
  creator: admin
)

template2 = LocationTemplate.create!(
  name: "Office",
  description: "Teacher office",
  creator: employee1
)

LocationTemplateItem.create!(location_template: template1, equipment_category: cat_records["Projector"])
LocationTemplateItem.create!(location_template: template1, equipment_category: cat_records["Monitor"])
LocationTemplateItem.create!(location_template: template1, equipment_category: cat_records["Mouse"])
LocationTemplateItem.create!(location_template: template1, equipment_category: cat_records["Keyboard"])
LocationTemplateItem.create!(location_template: template1, equipment_category: cat_records["Computer"])

LocationTemplateItem.create!(location_template: template2, equipment_category: cat_records["Computer"])
LocationTemplateItem.create!(location_template: template2, equipment_category: cat_records["Mouse"])
LocationTemplateItem.create!(location_template: template2, equipment_category: cat_records["Keyboard"])

puts "Creating sample tickets"
computer_category = EquipmentCategory.find_by!(name: "Computer")
projector_category = EquipmentCategory.find_by!(name: "Projector")
monitor_category = EquipmentCategory.find_by!(name: "Monitor")
smart_board_category = EquipmentCategory.find_by!(name: "Smart Board")

computer1_unit = Equipment.find_by!(location: office1, equipment_category: computer_category)
computer1_issue = IssueType.find_by!(name: "No Network", equipment_category: computer_category)

ticket1 = Ticket.create!(
    school: school1,
    location: office1,
    equipment: computer1_unit,
    issue_type: computer1_issue,
    description: "Computer cannot access Google Chrome",
    priority: :high,
    status: :in_progress,
    employee: employee2,
    assigned_at: Time.current
  )

projector_unit = Equipment.find_by!(location: class1, equipment_category: projector_category)
projector_issue = IssueType.find_by!(name: "No Visual", equipment_category: projector_category)

Ticket.create!(
    school: school1,
    location: class1,
    equipment: projector_unit,
    issue_type: projector_issue,
    priority: :low,
    status: :pending
  )

monitor_unit = Equipment.find_by!(location: class1, equipment_category: monitor_category)
monitor_issue = IssueType.find_by!(name: "Other", equipment_category: monitor_category)

ticket2 = Ticket.create!(
    school: school1,
    location: class1,
    equipment: monitor_unit,
    issue_type: monitor_issue,
    description: "Monitor stolen",
    priority: :medium,
    status: :completed,
    custom_issue_text: "Monitor missing",
    employee: employee1,
    assigned_at: Time.current
  )

smart_board_unit = Equipment.find_by!(location: class4, equipment_category: smart_board_category)
smart_board_issue = IssueType.find_by!(name: "Touchscreen Not Responding", equipment_category: smart_board_category)

Ticket.create!(
    school: school2,
    location: class4,
    equipment: smart_board_unit,
    issue_type: smart_board_issue,
    description: "Touchscreen detecting random places, not calibrated to my finger",
    priority: :low,
    status: :pending
  )

computer2_unit = Equipment.find_by!(location: office3, equipment_category: computer_category)
computer2_issue = IssueType.find_by!(name: "No Power", equipment_category: computer_category)

Ticket.create!(
    school: school3,
    location: office3,
    equipment: computer2_unit,
    issue_type: computer2_issue,
    priority: :medium,
    status: :in_progress,
    employee: employee3,
    assigned_at: Time.current
  )

Comment.create!(
    ticket: ticket1,
    user: school1,
    body: "Urgent, I need internet ASAP"
  )

Comment.create!(
  ticket: ticket1,
  user: employee2,
  body: "I will take a look at this on Monday."
)

Comment.create!(
  ticket: ticket2,
  user: employee3,
  body: "Monitor delivered"
)
