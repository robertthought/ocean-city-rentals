import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "checkIn", "checkOut", "dateFields", "noDates"]

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  // Debounced search for text inputs (300ms delay)
  debounceSearch() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.timeout = setTimeout(() => {
      this.search()
    }, 300)
  }

  // Immediate search for dropdowns, checkboxes, date inputs
  search() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    const form = this.hasFormTarget ? this.formTarget : this.element
    const formData = new FormData(form)
    const params = new URLSearchParams(formData)

    // Remove empty params for cleaner URLs
    const cleanParams = new URLSearchParams()
    for (const [key, value] of params) {
      if (value && value !== "" && value !== "0") {
        cleanParams.append(key, value)
      }
    }

    // Update URL for bookmarkability
    const url = `${form.action}?${cleanParams.toString()}`
    window.history.pushState({}, "", url)

    // Submit via Turbo
    form.requestSubmit()
  }

  // Toggle date fields visibility based on "I don't have dates yet" checkbox
  toggleDates(event) {
    const checked = event.target.checked

    if (this.hasDateFieldsTarget) {
      if (checked) {
        this.dateFieldsTarget.classList.add("hidden")
        // Clear date values when hiding
        if (this.hasCheckInTarget) this.checkInTarget.value = ""
        if (this.hasCheckOutTarget) this.checkOutTarget.value = ""
      } else {
        this.dateFieldsTarget.classList.remove("hidden")
      }
    }

    // Trigger search after toggling
    this.search()
  }

  // Update check-out min date when check-in changes
  updateCheckOutMin(event) {
    if (this.hasCheckOutTarget && event.target.value) {
      const checkInDate = new Date(event.target.value)
      checkInDate.setDate(checkInDate.getDate() + 1)
      const minCheckOut = checkInDate.toISOString().split('T')[0]
      this.checkOutTarget.min = minCheckOut

      // If check-out is before new min, clear it
      if (this.checkOutTarget.value && this.checkOutTarget.value < minCheckOut) {
        this.checkOutTarget.value = ""
      }
    }
    this.search()
  }
}
