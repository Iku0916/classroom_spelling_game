import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  add(event) {
    event.preventDefault()
    const time = new Date().getTime()

    const html = `
      <div class="card-row">
        <input type="text"
               name="word_kit[word_cards_attributes][${time}][english_word]"
               placeholder="英単語"
               class="input-field">

        <input type="text"
               name="word_kit[word_cards_attributes][${time}][japanese_translation]"
               placeholder="日本語"
               class="input-field">

        <label style="color: #e74c3c; font-size: 12px; min-width: 40px; text-align: center;">
          削除<br>
          <input type="checkbox" 
                 name="word_kit[word_cards_attributes][${time}][_destroy]" 
                 value="1">
        </label>
      </div>
    `

    this.containerTarget.insertAdjacentHTML("beforeend", html)

    const lastCard = this.containerTarget.lastElementChild
    lastCard.scrollIntoView({ behavior: "smooth", block: "center" })

    const englishInput = lastCard.querySelector(".english-input")
    if (englishInput) englishInput.focus()
  }
}