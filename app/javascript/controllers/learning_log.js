import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["score"]

  connect() {
    this.startTime = Date.now()
  }

  finish(e) {
    e.preventDefault()

    document.getElementById("learning-score").value = this.currentScore
    document.getElementById("learning-minutes").value = this.timeLimitValue

    e.target.closest("form").submit()
  }
}