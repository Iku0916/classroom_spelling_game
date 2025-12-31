import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "answer", "feedback"]

  connect() {
    console.log("Game controller connected!") // デバッグ用
    this.index = 0
    this.questions = JSON.parse(this.element.dataset.gameQuestions)
    console.log("Questions:", this.questions) // デバッグ用
    this.showQuestion()
  }

  showQuestion() {
    const current = this.questions[this.index]
    this.questionTarget.textContent = current.japanese_translation
    this.answerTarget.value = ""
    this.feedbackTarget.textContent = ""
  }

  submitAnswer(event) {
    console.log("submitAnswer called!") // デバッグ用
    
    // Enterキーの場合のみpreventDefaultが必要
    if (event.type === "keydown") {
      event.preventDefault()
    }
    
    const userAnswer = this.answerTarget.value.trim()
    const current = this.questions[this.index]

    if(userAnswer === current.english_word) {
      this.feedbackTarget.textContent = "正解!🎉"
      this.feedbackTarget.style.color = "green"
    } else {
      this.feedbackTarget.textContent = `不正解… 正解は: ${current.english_word}`
      this.feedbackTarget.style.color = "red"
    }

    // 次の問題に進む
    this.index++
    if(this.index >= this.questions.length) {
      this.index = 0
    }

    // 1.5秒後に次の問題に切り替え
    setTimeout(() => {
      this.showQuestion()
    }, 1500)
  }
}