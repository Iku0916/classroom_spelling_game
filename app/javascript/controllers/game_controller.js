import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "feedback", "wordInputContainer", "progressBar", "progressBarFill"]
  static values = {
    questions: Array
  }

  connect() {
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

    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = ""
      this.feedbackTarget.className = "feedback-text"
    }

    if (this.hasQuestionTarget) {
      this.questionTarget.textContent = current.correct_answer
    }

    this.wordInputContainerTarget.innerHTML = ""
    
    const wrapper = document.createElement("div")
    wrapper.className = "vocano-word-wrapper"
    wrapper.setAttribute("data-controller", "word-input")

    current.word.split("").forEach((char, idx) => {
      const input = document.createElement("input")
      input.type = "text"
      input.maxLength = 1
      input.className = "vocano-letter-box" 
      input.setAttribute("data-word-input-target", "letter")
      input.setAttribute("data-index", idx.toString())
      wrapper.appendChild(input)
    })

    this.wordInputContainerTarget.appendChild(wrapper)
    const firstInput = wrapper.querySelector('input')
    if (firstInput) firstInput.focus()
  }

  submitAnswer(event) {
    if (this.isLocked) return
    if (event instanceof KeyboardEvent && event.key !== "Enter") return
    if (event instanceof KeyboardEvent) event.preventDefault()

    const wordInputEl = document.querySelector('[data-controller="word-input"]')
    if (!wordInputEl) return

    const wordInputController = this.application.getControllerForElementAndIdentifier(
      wordInputEl,
      "word-input"
    )
    if (!wordInputController) return

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
        this.feedbackTarget.className = "feedback-text feedback-correct"
      }
      if (scoreController) scoreController.add()
      this.waitingForNext = true
    } else {
      if (this.hasFeedbackTarget) {
        this.feedbackTarget.innerHTML = `ざんねん…😢 -1ポイント <br> 正解は: ${current.word}`;
        this.feedbackTarget.className = "feedback-text feedback-incorrect"
      }
      if (scoreController) scoreController.subtract()
      this.isLocked = true

      if (this.hasProgressBarTarget) {
        this.progressBarTarget.style.display = "block"
        this.progressBarFillTarget.style.width = "100%"
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.progressBarFillTarget.style.width = "0%"
          })
        })
      }

      setTimeout(() => {
        this.index = (this.index + 1) % this.questions.length
        this.showQuestion()
        this.isLocked = false

        if (this.hasProgressBarTarget) {
          this.progressBarTarget.style.display = "none"
          this.progressBarFillTarget.style.width = "100%"
        }
      }, 3000)
    }
  }
}