import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["display"]
  static values = {
    timeLimit: Number,
    startedAt: String,
    gameRoomId: Number,
    isHost: String,
    participantId: Number
  }

  connect() {
    if (this.isHostValue !== 'true') this.setupActionCable()

    if (!this.startedAtValue) {
      if (this.hasDisplayTarget) this.displayTarget.textContent = "--:--"
      return
    }
    
    const startTime = new Date(this.startedAtValue).getTime()
    const elapsed = Math.max(0, Math.floor((Date.now() - startTime) / 1000))
    let remaining = Math.max(0, this.timeLimitValue - elapsed)

    this.updateDisplay(remaining)
    if (remaining <= 0) return this.timeUp()

    this.interval = setInterval(() => {
      remaining--
      this.updateDisplay(remaining)
      if (remaining <= 0) {
        clearInterval(this.interval)
        this.timeUp()
      }
    }, 1000)
  }

  confirmFinish() {
    if (confirm("ゲームを終了しますか？")) {
      this.callFinish()
    }
  }

  setupActionCable() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "GameChannel", game_room_id: this.gameRoomIdValue },
      {
        received: (data) => {
          if (data.type === 'game_finished') {
            window.location.href = `/game_rooms/${this.gameRoomIdValue}/game_play/personal_result`
          }
        }
      }
    )
  }

  updateDisplay(seconds) {
    if (!this.hasDisplayTarget) return
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    this.displayTarget.textContent = `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
  }

  async timeUp() {
    const scoreController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="score"]'), "score"
    )
    const finalScore = scoreController?.score || 0

    this.isHostValue === 'true' ? await this.callFinish() : await this.saveScore(finalScore)
  }

  async saveScore(score) {
    try {
      await fetch(`/game_rooms/${this.gameRoomIdValue}/game_play/update_score`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ score })
      })
    } catch (err) {
      console.error("スコア保存エラー:", err)
    }
  }

  async callFinish() {
    try {
      const response = await fetch(`/game_rooms/${this.gameRoomIdValue}/game_play/finish`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      const data = await response.json()
      if (data.success && data.redirect_url) {
        setTimeout(() => { window.location.href = data.redirect_url }, 2000)
      }
    } catch (error) {
      console.error("ゲーム終了処理エラー:", error)
    }
  }

  disconnect() {
    clearInterval(this.interval)
    this.channel?.unsubscribe()
  }
}