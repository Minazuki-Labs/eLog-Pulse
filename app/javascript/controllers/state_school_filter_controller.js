import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["state", "school", "location", "equipment"]

  filterState() {
    const state = this.hasStateTarget ? this.stateTarget.value : ""
    
    if (this.hasSchoolTarget) {
      this.schoolTarget.innerHTML = '<option value="">All Schools</option>'
      this.schoolTarget.value = ""
    }
    if (this.hasLocationTarget) {
      this.locationTarget.innerHTML = '<option value="">All Locations</option>'
      this.locationTarget.value = ""
    }
    if (this.hasEquipmentTarget) {
      this.equipmentTarget.innerHTML = '<option value="">All Equipment</option>'
      this.equipmentTarget.value = ""
    }

    if (!state) return

    fetch(`/tickets/schools_by_state?state=${encodeURIComponent(state)}`)
      .then(response => response.json())
      .then(schools => {
        schools.forEach(school => {
          const option = document.createElement("option")
          option.value = school.id
          option.textContent = school.name || school.email
          this.schoolTarget.appendChild(option)
        })
      })
      .catch(error => {
        console.error("Failed to load schools for the selected state:", error)
      })
  }

  filterSchool() {
    const schoolId = this.hasSchoolTarget ? this.schoolTarget.value : ""

    if (this.hasLocationTarget) {
      this.locationTarget.innerHTML = '<option value="">All Locations</option>'
      this.locationTarget.value = ""
    }
    if (this.hasEquipmentTarget) {
      this.equipmentTarget.innerHTML = '<option value="">All Equipment</option>'
      this.equipmentTarget.value = ""
    }

    if (!schoolId) return

    fetch(`/tickets/locations?school_id=${encodeURIComponent(schoolId)}`)
      .then(response => response.json())
      .then(locations => {
        locations.forEach(location => {
          const option = document.createElement("option")
          option.value = location.id
          option.textContent = location.name
          this.locationTarget.appendChild(option)
        })
      })
      .catch(error => {
        console.error("Failed to load locations for the selected school:", error)
      })
  }

  filterLocation() {
    const locationId = this.hasLocationTarget ? this.locationTarget.value : ""

    if (this.hasEquipmentTarget) {
      this.equipmentTarget.innerHTML = '<option value="">All Equipment</option>'
      this.equipmentTarget.value = ""
    }

    if (!locationId) return

    fetch(`/tickets/equipment?location_id=${encodeURIComponent(locationId)}`)
      .then(response => response.json())
      .then(equipmentList => {
        equipmentList.forEach(item => {
          const option = document.createElement("option")
          option.value = item.id
          option.textContent = item.name
          this.equipmentTarget.appendChild(option)
        })
      })
      .catch(error => {
        console.error("Failed to load equipment for the selected location:", error)
      })
  }
}
