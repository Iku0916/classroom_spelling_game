import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  open() {
    console.log("open called")
    this.containerTarget.classList.remove("hidden")
  }

  close() {
    console.log("close called")
    this.containerTarget.classList.add("hidden")
  }
}