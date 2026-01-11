import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  open() {
    this.panelTarget.classList.add("open")
    this.overlayTarget.classList.add("open")
  }

  close() {
    this.panelTarget.classList.remove("open")
    this.overlayTarget.classList.remove("open")
  }
}
