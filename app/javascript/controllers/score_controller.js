import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]
  static values = { gameRoomId: Number }

  connect() {
    console.log("✅ score コントローラー接続成功") 
    this.score = 0
    this.scoreSaved = false
    this.gameFinished = false
    this.render()
  }

  add() {
    this.score += 1
    this.render()
    this.saveToServer()
  }

  subtract() {
    this.score -= 1
    this.render()
    this.saveToServer()
  }

  render() {
    this.valueTarget.textContent = this.score
  }

  getScore() {
    return this.score
  }

  async saveToServer() {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const roomId = this.gameRoomIdValue 

    if (!roomId) return

    try {
      await fetch(`/game_rooms/${roomId}/game_play/update_score`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": token,
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: JSON.stringify({ score: this.score })
      })
      console.log(`📡 スコア同期中... (${this.score}点)`)
    } catch (err) {
      console.error("Score sync error:", err)
    }
  }
}