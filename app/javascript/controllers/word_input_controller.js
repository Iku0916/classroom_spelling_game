import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["letter"]

  connect() {
    this.letterTargets.forEach((input, idx) => {
      input.addEventListener("input", (e) => this.onInput(e, idx))
      input.addEventListener("keydown", (e) => this.onBackspace(e, idx))
    })
  }

  onInput(event, idx) {
    const input = event.target
    // 入力したら次の入力欄に移動
    if (input.value.length >= 1 && idx < this.letterTargets.length - 1) {
      this.letterTargets[idx + 1].focus()
    }
  }

  onBackspace(event, idx) {
    const input = event.target
    if (event.key === "Backspace" && idx > 0 && input.value === "") {
      // 前の入力欄に戻る
      this.letterTargets[idx - 1].focus()
    }
  }

  // もしsubmit時に文字列まとめて取得したい場合
  getAnswer() {
    return this.letterTargets.map(input => input.value).join("")
  }
}