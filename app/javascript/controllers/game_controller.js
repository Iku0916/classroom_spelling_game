import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "feedback"]
  static values = {
    questions: Array
  }

  connect() {
    console.log("connected element:", this.element)
    console.log("questionsValue:", this.questionsValue)

    this.questions = this.questionsValue
    this.index = 0
    this.isLocked = false
    this.waitingForNext = false

    this.showQuestion()

    this.element.addEventListener("keydown", (e) => {
      if (e.key === "Enter") this.submitAnswer(e)
    })
  }

  showQuestion() {
    const current = this.questions[this.index]
    if (!current) return

    if (this.hasFeedbackTarget) this.feedbackTarget.textContent = ""
    if (this.hasQuestionTarget) this.questionTarget.textContent = current.correct_answer

    const oldWordInput = document.querySelector('[data-controller="word-input"]')
    if (oldWordInput) oldWordInput.remove()

    const wordInputDiv = document.createElement("div")
    wordInputDiv.setAttribute("data-controller", "word-input")

    current.word.split("").forEach((char, idx) => {
      const input = document.createElement("input")
      input.type = "text"
      input.maxLength = 1
      input.className = "letter-input"
      input.setAttribute("data-word-input-target", "letter")
      input.setAttribute("data-index", idx.toString())
      wordInputDiv.appendChild(input)
    })

    const questionEl = this.hasQuestionTarget ? this.questionTarget : null
    if (questionEl && questionEl.parentNode) {
      questionEl.parentNode.insertBefore(wordInputDiv, questionEl)
    } else {
      console.warn("question element or parent not found")
    }

    const firstInput = wordInputDiv.querySelector('input')
    if (firstInput) firstInput.focus()
  }

  submitAnswer(event) {
    if (this.isLocked) return

    if (event instanceof KeyboardEvent && event.key !== "Enter") return
    if (event instanceof KeyboardEvent) event.preventDefault()

    const wordInputEl = document.querySelector('[data-controller="word-input"]')
    if (!wordInputEl) {
      console.warn("word-input controller instance not found")
      return
    }

    const wordInputController = this.application.getControllerForElementAndIdentifier(
      wordInputEl,
      "word-input"
    )
    if (!wordInputController) {
      console.warn("word-input controller instance not found")
      return
    }

    const userAnswer = wordInputController.getAnswer().trim()
    const current = this.questions[this.index]

    const scoreController = this.application.getControllerForElementAndIdentifier(
      this.element,
      "score"
    )

    if (this.waitingForNext) {
      this.waitingForNext = false
      this.index = (this.index + 1) % this.questions.length
      this.showQuestion()
      return
    }

    if (userAnswer.toLowerCase() === current.word.toLowerCase()) {
      if (this.hasFeedbackTarget) {
        this.feedbackTarget.textContent = "正解！🎉 +1ポイント"
        this.feedbackTarget.style.color = "green"
      }
      if (scoreController) scoreController.add()
      this.waitingForNext = true
    } else {
      if (this.hasFeedbackTarget) {
        this.feedbackTarget.textContent = `ざんねん…😢 -1ポイント 正解は: ${current.word}`
        this.feedbackTarget.style.color = "red"
      }
      if (scoreController) scoreController.subtract()
      this.isLocked = true

      setTimeout(() => {
        this.index = (this.index + 1) % this.questions.length
        this.showQuestion()
        this.isLocked = false
      }, 3000)
    }
  }
}