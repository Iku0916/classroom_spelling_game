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
    console.log("✅ timer_controller connected")
    console.log("⏰ 制限時間:", this.timeLimitValue, "秒")
    console.log("⏰ 開始時刻:", this.startedAtValue)
    console.log("🎮 ゲームルームID:", this.gameRoomIdValue)
    console.log("👤 ホストかどうか:", this.isHostValue)
    console.log("👤 参加者ID:", this.participantIdValue)

    // 参加者の場合だけ ActionCable に接続
    if (this.isHostValue !== 'true') {
    this.setupActionCable()
    }

    // started_atが空の場合は処理しない
    if (!this.startedAtValue) {
      console.warn("⚠️ started_atが設定されていません")
      if (this.hasDisplayTarget) {
        this.displayTarget.textContent = "--:--"
      }
      return
    }
    
    // ゲーム開始時刻から残り時間を計算
    const startTime = new Date(this.startedAtValue).getTime()
    const now = Date.now()
    const elapsed = Math.floor((now - startTime) / 1000)
    let remaining = Math.max(0, this.timeLimitValue - elapsed)
    
    console.log(`⏰ 経過時間: ${elapsed}秒`)
    console.log(`⏰ 残り時間: ${remaining}秒`)
    
    this.score = 0
    this.updateDisplay(remaining)

    // すでに時間切れの場合は即座に終了
    if (remaining <= 0) {
      this.timeUp()
      return
    }

    // タイマーを開始
    this.interval = setInterval(() => {
      remaining--
      this.updateDisplay(remaining)

      if (remaining <= 0) {
        clearInterval(this.interval)
        this.timeUp()
      }
    }, 1000)
  }

  setupActionCable() {
    console.log('📡 ActionCable 接続開始...')
    
    const gameRoomId = this.gameRoomIdValue
    
    this.channel = createConsumer().subscriptions.create(
      {
        channel: "GameChannel",
        game_room_id: gameRoomId
      },
      {
        connected() {
          console.log(`✅ ActionCable 接続成功 (ゲームルーム: ${gameRoomId})`)
        },

        disconnected() {
          console.log('❌ ActionCable 接続切断')
        },

        // ✅ アロー関数に変更して this を使えるようにする
        received: (data) => {
          console.log('📨 ActionCable データ受信:', data)
          console.log('📨 データタイプ:', data.type)
          
          if (data.type === 'game_finished') {
            console.log('🎮 game_finished を受信！リダイレクトします')
            
            // ✅ this.gameRoomIdValue を使う
            const redirectUrl = `/game_rooms/${this.gameRoomIdValue}/game_play/personal_result`
            console.log('🔄 リダイレクト先:', redirectUrl)
            
            // リダイレクト実行
            window.location.href = redirectUrl
          }
        }
      }
    )
  }

  updateDisplay(seconds) {
    if (!this.hasDisplayTarget) return
    
    const minutes = Math.floor(seconds / 60)
    const secs = seconds % 60
    
    this.displayTarget.textContent = 
      `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
  }

  addScore(points) {
    this.score += points
    console.log(`✅ スコア加算: ${points}点 (合計: ${this.score}点)`)
  }

  async timeUp() {
    console.log("⏰ 時間切れ！")
    console.log('=== デバッグ情報 ===');
    console.log('this.isHostValue:', this.isHostValue);
    console.log('typeof this.isHostValue:', typeof this.isHostValue);
    console.log('this.isHostValue === "true":', this.isHostValue === 'true');
    console.log('this.participantIdValue:', this.participantIdValue);
    console.log('===================');

    const scoreElement = document.querySelector('[data-controller~="score"]')
    let finalScore = 0

    if (scoreElement) {
      const scoreController = this.application.getControllerForElementAndIdentifier(
        scoreElement,
        "score"
      )
      
      if (scoreController && scoreController.score !== undefined) {
        finalScore = scoreController.score  // ★ score コントローラーから取得
        console.log('📊 score コントローラーから取得したスコア:', finalScore)
      } else {
        console.log('⚠️ score コントローラーが見つかりません')
      }
    } else {
      console.log('⚠️ score コントローラーの要素が見つかりません')
    }
    
    console.log('📊 最終スコア:', finalScore)

    if (this.isHostValue === 'true') {
      // ホストの場合
      console.log('🎮 ホストとして全員のスコア保存とゲーム終了を実行...');
      await this.callFinish();
      
    } else {
      // 参加者の場合
      console.log('👤 参加者としてスコアを保存...');
      await this.saveScore(finalScore);
      
      console.log('👤 ActionCable の通知を待機中...');
      // ActionCableの通知を待つ（received() メソッドで処理）
    }
  }

  async saveScore(score) {
    console.log("💾 スコアを保存中...")
    console.log('📊 保存するスコア:', score)
    
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    
    try {
      const response = await fetch(`/game_rooms/${this.gameRoomIdValue}/game_play/update_score`, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": token,
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: JSON.stringify({ score: score })
      })
      
      console.log('📡 送信したデータ:', JSON.stringify({ score: score }))

      if (response.ok) {
        const data = await response.json()
        console.log("✅ スコア保送成功", data)
        
        this.scoreSaved = true
        
        if (this.gameFinished) {
          this.redirectToResult()
        }
      } else {
        console.error("❌ スコア保存失敗", response.status)
      }
    } catch (err) {
      console.error("❌ スコア保存エラー", err)
    }
  }

  async callFinish() {
    console.log('🏁 ゲーム終了を通知中...')
    
    try {
      const response = await fetch(`/game_rooms/${this.gameRoomIdValue}/game_play/finish`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })
      
      const data = await response.json()
      console.log('✅ finishアクション成功:', data)
      
      if (data.success && data.redirect_url) {
        console.log('🔄 リダイレクト実行:', data.redirect_url)
        
        setTimeout(() => {
          window.location.href = data.redirect_url
        }, 3000)
      } else {
        console.error('❌ リダイレクト条件を満たしていません:', data)
        alert('ゲーム終了に失敗しました')
      }
    } catch (error) {
      console.error('❌ finishアクション失敗:', error)
      alert('エラーが発生しました')
    }
  }

  disconnect() {
  // タイマーのクリア
    if (this.interval) {
      clearInterval(this.interval)
    }
    
    // ✅ ActionCable の切断を追加
    if (this.channel) {
      this.channel.unsubscribe()
    }
  }
}