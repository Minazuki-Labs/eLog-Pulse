import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["school", "location", "equipment", "issueType"]
  static values = { locationsUrl: String, equipmentUrl: String, issueTypesUrl: String }

  connect() {
    if (this.hasSchoolTarget && this.schoolTarget.value && this.locationTarget.options.length <= 1) {
      this.updateLocations();
    }
  }

  updateLocations() {
    const schoolId = this.schoolTarget.value
    this.clearTarget(this.locationTarget)
    this.clearTarget(this.equipmentTarget)
    this.clearTarget(this.issueTypeTarget)
    
    if (!schoolId) return
    this.fetchData(`${this.locationsUrlValue}?school_id=${schoolId}`, this.locationTarget)
  }

  updateEquipment() {
    const locationId = this.locationTarget.value
    this.clearTarget(this.equipmentTarget)
    this.clearTarget(this.issueTypeTarget)

    if (!locationId) return
    this.fetchData(`${this.equipmentUrlValue}?location_id=${locationId}`, this.equipmentTarget)
  }

  updateIssueTypes() {
    const equipmentId = this.equipmentTarget.value

    if (!equipmentId) return
    this.fetchData(`${this.issueTypesUrlValue}?equipment_id=${equipmentId}`, this.issueTypeTarget)
  }

  fetchData(url, target) {
    fetch(url, {
        headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
        }
    })
        .then(response => {
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        return response.json();
        })
        .then(data => {
            target.innerHTML = '<option value="">Select...</option>'
            data.forEach(item => {
                const option = new Option(item.name || item.display_name || item.id, item.id) 
                target.add(option)
            })
        })
        .catch(error => console.error("Error fetching data:", error))
    }

  clearTarget(target) {
    target.innerHTML = '<option value="">Select...</option>'
  }
}
