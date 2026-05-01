import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static targets = ["school", "location", "equipment", "issueType"]
  static values = { locationsUrl: String, equipmentUrl: String, issueTypesUrl: String }

connect() {
  const elements = [
    this.hasSchoolTarget ? this.schoolTarget : null,
    this.hasLocationTarget ? this.locationTarget : null,
    this.hasEquipmentTarget ? this.equipmentTarget : null,
    this.hasIssueTypeTarget ? this.issueTypeTarget : null
  ].filter(el => el !== null)

  this.instances = elements.map(el => this.initTomSelect(el))

  if (this.hasSchoolTarget && this.schoolTarget.value && this.locationTarget.options.length <= 1) {
    this.updateLocations();
  }
}

  initTomSelect(el) {
    if (el.tomselect) return el.tomselect
    return new TomSelect(el, {
      create: false,
      placeholder: el.getAttribute('placeholder') || "Search...",
      allowEmptyOption: true,
      maxOptions: 100,
      plugins: ['dropdown_input'],
      searchField: ['text'],
      onInitialize: function() {
        this.wrapper.classList.add('w-full', 'rounded-2xl', 'border-none');
        this.control.classList.add('rounded-2xl', 'bg-slate-50', 'border-none', 'p-4');
    }
    })
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
    .then(response => response.json())
    .then(data => {
      const ts = target.tomselect
      ts.clear()
      ts.clearOptions()

      data.forEach(item => {
        ts.addOption({
          value: item.id,
          text: item.name || item.display_name || item.id
        })
      })
      
      ts.refreshOptions(false)
    })
    .catch(error => console.error("Error fetching data:", error))
  }

  clearTarget(target) {
    if (target && target.tomselect) {
      target.tomselect.clear()
      target.tomselect.clearOptions()
    }
  }

  disconnect() {
    if (this.hasSchoolTarget) this.schoolTarget.tomselect?.destroy()
    if (this.hasLocationTarget) this.locationTarget.tomselect?.destroy()
    if (this.hasEquipmentTarget) this.equipmentTarget.tomselect?.destroy()
    if (this.hasIssueTypeTarget) this.issueTypeTarget.tomselect?.destroy()
  }
}
