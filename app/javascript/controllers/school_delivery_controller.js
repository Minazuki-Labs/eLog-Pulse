import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["schoolSelect"]
  static values = { deliveryOrders: Object }

  checkDelivery(event) {
    const schoolId = event.target.value
    const orderId = this.deliveryOrdersValue[schoolId]

    if (orderId) {
      if (window.confirm("An order for this school is currently out for delivery. Have these items arrived?")) {
        this.markOrderCompleted(orderId)
      }
    }
  }

  markOrderCompleted(orderId) {
    fetch(`/stock_orders/${orderId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      },
      body: JSON.stringify({ stock_order: { status: "completed" } })
    }).then(response => {
      if (response.ok) {
        window.location.reload()
      }
    })
  }
}
