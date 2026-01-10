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
    this.isLocked = false

    this.showQuestion()
  }

  showQuestion() {
    const current = this.questions[this.index]

    this.questionTarget.textContent = current.correct_answer
    this.answerTarget.value = ""
    this.feedbackTarget.textContent = ""
  }

  submitAnswer(event) {
    if (this.isLocked) return
    if (event.type === "keydown" && event.key !== "Enter") return
    if (event.type === "keydown") event.preventDefault()

    const userAnswer = this.answerTarget.value.trim()
    const current = this.questions[this.index]

    const scoreController =
      this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="score"]'),
        "score"
      )

    if (this.waitingForNext) {
      this.waitingForNext = false
      this.index = (this.index + 1) % this.questions.length
      this.showQuestion()
      return
    }

    if (userAnswer.toLowerCase() === current.word.toLowerCase()) {
      this.feedbackTarget.textContent = "正解！🎉 +1ポイント"
      this.feedbackTarget.style.color = "green"
      scoreController.add()

      this.waitingForNext = true
    } else {
      this.feedbackTarget.textContent =
        `ざんねん…😢 -1ポイント 正解は: ${current.word}`
      this.feedbackTarget.style.color = "red"
      scoreController.subtract()

      this.isLocked = true

      setTimeout(() => {
        this.index = (this.index + 1) % this.questions.length
        this.showQuestion()
        this.isLocked = false
      }, 3000)
    }
  }
}