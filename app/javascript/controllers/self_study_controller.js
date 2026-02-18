import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "inputContainer", "timer", "score", "feedback"]
  static values = { 
    questions: Array, 
    timeLimit: Number,
    answerUrl: String
  }

  connect() {
    this.index = 0
    this.currentScore = 0
    this.remainingTime = this.timeLimitValue || 60
    this.isLocked = false

    this.showQuestion()
    this.startTimer()
  }

  showQuestion() {
    const current = this.questionsValue[this.index]
    if (!current) return

    this.questionTarget.textContent = current.correct_answer

    this.feedbackTarget.textContent = ""
    this.feedbackTarget.className = "feedback-text"

    this.inputContainerTarget.innerHTML = ""
    const wordInputDiv = document.createElement("div")
    wordInputDiv.className = "word-input-container"

    current.word.split("").forEach((char, idx) => {
      const input = document.createElement("input")
      input.type = "text"
      input.maxLength = 1
      input.className = "letter-box"
      input.setAttribute("data-word-input-target", "letter")
      input.setAttribute("data-index", idx.toString())

      input.addEventListener("input", (e) => {
        if (e.target.value.length === 1) {
          const nextInput = wordInputDiv.querySelectorAll('input')[idx + 1]
          if (nextInput) {
            nextInput.focus()
          }
        }
      })

      input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
          e.preventDefault()

          if (this.awaitingNext) {
            this.awaitingNext = false
            this.isLocked = false
            this.index = (this.index + 1) % this.questionsValue.length
            this.showQuestion()
          } else {
            this.submitAnswer()
          }
        } else if (e.key === "Backspace" && e.target.value === "") {
          const prevInput = wordInputDiv.querySelectorAll('input')[idx - 1]
          if (prevInput) prevInput.focus()
        }
      })

      wordInputDiv.appendChild(input)
    })
    this.inputContainerTarget.appendChild(wordInputDiv)
    const firstInput = wordInputDiv.querySelector('input')
    if (firstInput) firstInput.focus()
  }

  async submitAnswer() {
    if (this.awaitingNext) {
      this.awaitingNext = false
      this.isLocked = false
      this.index = (this.index + 1) % this.questionsValue.length
      this.showQuestion()
      return
    }

    if (this.isLocked) return

    const current = this.questionsValue[this.index]
    const correctAnswer = current.word.toLowerCase()
    const inputs = this.inputContainerTarget.querySelectorAll("input")
    const userAnswer = Array.from(inputs).map(i => i.value).join("").toLowerCase()

    if (userAnswer === correctAnswer) {
      this.currentScore++
      this.scoreTarget.textContent = this.currentScore
      this.feedbackTarget.textContent = "正解！🎉 +1ポイント"
      this.feedbackTarget.className = "feedback-text correct";

      await fetch(this.answerUrlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({ answer: userAnswer })
      })

      this.isLocked = true
      this.awaitingNext = true

    } else {

      this.currentScore--
      this.scoreTarget.textContent = this.currentScore
      
      this.feedbackTarget.textContent = `ざんねん…😢 正解は: ${current.word}`
      this.feedbackTarget.className = "feedback-text incorrect";
      this.isLocked = true

      setTimeout(() => {
        this.index = (this.index + 1) % this.questionsValue.length
        this.showQuestion()
        this.isLocked = false
      }, 3000)
    }
  }

  startTimer() {
    this.interval = setInterval(() => {
      this.remainingTime--
      
      const minutes = Math.floor(this.remainingTime / 60)
      const seconds = this.remainingTime % 60
      
      const displaySeconds = String(seconds).padStart(2, '0')
      
      this.timerTarget.textContent = `${minutes}:${displaySeconds}`

      if (this.remainingTime <= 0) {
        clearInterval(this.interval)
        this.finishGame()
      }
    }, 1000)
  }

  async finishGame() {
    const wordKitId = window.location.pathname.split('/')[2];
    const updateUrl = `/word_kits/${wordKitId}/self_study`;

    await fetch(updateUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        score: this.currentScore,
        minutes: (this.timeLimitValue - this.remainingTime) / 60,
        word_kit_id: wordKitId
      })
    });
      window.location.href = `/word_kits/${wordKitId}/self_study/result?score=${this.currentScore}`;
  }
}