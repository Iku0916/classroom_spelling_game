import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "liveCards", "english", "japanese"]

  connect() {
    this.formTarget.addEventListener("submit", e => this.addCard(e))
  }

  addCard(e) {
    if (e.submitter && e.submitter.name === 'finished') return;
    e.preventDefault()

    const english = this.englishTarget.value.trim()
    const japanese = this.japaneseTarget.value.trim()
    if (!english || !japanese) return

    const cardDiv = document.createElement('div')
    cardDiv.className = 'card'
    cardDiv.innerHTML = `<p><strong>${english}</strong> - ${japanese}</p>`
    this.liveCardsTarget.appendChild(cardDiv)

    this.englishTarget.value = ''
    this.japaneseTarget.value = ''
  }
}