import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer"]

  connect() {
    const element = this.timerTarget
    let remaining = parseInt(element.dataset.timeLimit, 10)
    this.updateDisplay(remaining)

    this.interval = setInterval(() => {
      remaining--
      if (remaining < 0) {
        clearInterval(this.interval)
        return
      }
      this.updateDisplay(remaining)
    }, 1000)
  }

  updateDisplay(seconds) {
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    this.timerTarget.textContent = `${minutes}:${secs.toString().padStart(2, '0')}`
  }
}
