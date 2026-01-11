import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  add() {
    const time = new Date().getTime()

    const html = `
      <div class="card-row">
        <input type="text"
               name="word_kit[word_cards_attributes][${time}][english_word]"
               placeholder="英単語"
               class="english-input">

        <input type="text"
               name="word_kit[word_cards_attributes][${time}][japanese_translation]"
               placeholder="日本語"
               class="japanese-input">
      </div>
    `

    this.containerTarget.insertAdjacentHTML("beforeend", html)

    const lastCard = this.containerTarget.lastElementChild

    lastCard.scrollIntoView({ behavior: "smooth", block: "center" })

    const englishInput = lastCard.querySelector(".english-input")
    if (englishInput) englishInput.focus()
  }
}