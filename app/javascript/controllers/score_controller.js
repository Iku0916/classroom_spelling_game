import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]

  connect() {
    this.score = 0
    this.scoreSaved = false
    this.gameFinished = false
    this.render()
  }

  add() {
    this.score += 1
    this.render()
  }

  subtract() {
    this.score -= 1
    this.render()
  }

  render() {
    this.valueTarget.textContent = this.score
  }
}