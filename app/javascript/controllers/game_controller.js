import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "answer", "feedback"]
  static values = {
    questions: Array
  }

  connect() {
    console.log("connected element:", this.element)
    console.log("questionsValue:", this.questionsValue)

    this.questions = this.questionsValue
    this.index = 0

    this.showQuestion()
  }

  showQuestion() {
    const current = this.questions[this.index]

    this.questionTarget.textContent = current.japanese_translation
    this.answerTarget.value = ""
    this.feedbackTarget.textContent = ""
  }

  submitAnswer(event) {
    if (event.type === "keydown") event.preventDefault()

    const userAnswer = this.answerTarget.value.trim()
    const current = this.questions[this.index]

    const scoreController =
      this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="score"]'),
        "score"
      )

    if (userAnswer.toLowerCase() === current.english_word.toLowerCase()) {
      this.feedbackTarget.textContent = "正解！🎉 +1ポイント"
      this.feedbackTarget.style.color = "green"
      scoreController.add()
    } else {
      this.feedbackTarget.textContent =
        `ざんねん…😢 -1ポイント 正解は: ${current.english_word}`
      this.feedbackTarget.style.color = "red"
      scoreController.subtract()
    }

    this.index = (this.index + 1) % this.questions.length

    setTimeout(() => this.showQuestion(), 1500)
  }
}