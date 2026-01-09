import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  
  // ===== 待機画面の処理 =====
  const gameWaiting = document.getElementById('game_waiting');

  if (gameWaiting) {
    console.log("=== 待機画面を検知 ===");
    const roomId = gameWaiting.dataset.roomId;
    console.log(`=== サブスクライブ開始: room ${roomId} ===`);

    consumer.subscriptions.create(
      { channel: "GameChannel", game_room_id: roomId },
      {
        connected() {
          console.log("✅ GameChannel接続成功（待機画面）");
        },

        disconnected() {
          console.log("❌ GameChannel切断（待機画面）");
        },

        received(data) {
          console.log("📨 メッセージ受信（待機画面）:", data);

          if (data.type === "game_start") {
            console.log("🎮 ゲーム開始！");

            const messageDiv = document.createElement('div');
            messageDiv.className = 'alert alert-success';
            messageDiv.textContent = data.message;

            const container = document.querySelector('.container');
            if (container) {
              container.prepend(messageDiv);
            }

            setTimeout(() => {
              console.log("🔄 リダイレクト実行:", data.redirect_url);
              window.location.href = data.redirect_url;
            }, 0);
          }
        }
      }
    );
  }

  // ===== プレイ画面の処理 =====
  const gamePlay = document.getElementById('game_play');  // ⭐️ gamePlay

  if (gamePlay) {  // ⭐️ gamePlay
    console.log("=== プレイ画面を検知 ===");
    const roomId = gamePlay.dataset.roomId;  // ⭐️ gamePlay に修正
    console.log("🎮 ゲームルームID:", roomId);
    
    if (!roomId) {
      console.error("❌ room_id が取得できませんでした");
      return;
    }
    
    consumer.subscriptions.create(
      { channel: "GameChannel", room_id: roomId },
      {
        connected() {
          console.log("✅ GameChannel接続成功(プレイ画面)");
        },

        disconnected() {
          console.log("❌ GameChannel接続解除(プレイ画面)");
        },

        received(data) {
          console.log("📨 メッセージ受信(プレイ画面):", data);
          
          if (data.type === "game_finished") {
            console.log("🏁 ゲーム終了メッセージ受信");
            
            // ⭐️ 自分の役割に応じてリダイレクト先を計算
            const participantId = document.querySelector('[data-participant-id]')?.dataset.participantId;
            const isHost = document.querySelector('[data-is-host="true"]');
            
            let redirectUrl;
            
            if (isHost) {
              // ホストの場合
              redirectUrl = `/game_rooms/${roomId}/game_play/overall_result`;
              console.log("👑 ホストなので overall_result へ:", redirectUrl);
            } else if (participantId) {
              // 参加者の場合
              redirectUrl = `/game_rooms/${roomId}/participants/${participantId}/personal_result`;
              console.log("👤 参加者なので personal_result へ:", redirectUrl);
            } else {
              console.error("❌ participant_id が取得できませんでした");
              return;
            }
            
            // メッセージ表示
            alert(data.message);
            
            // リダイレクト実行
            setTimeout(() => {
              console.log("🔄 リダイレクト実行:", redirectUrl);
              window.location.href = redirectUrl;
            }, 1000);
          } else {
            console.log("⚠️ game_finished 以外のメッセージ:", data.type);
          }
        }
      }
    );
  } else {
    console.log("ℹ️ プレイ画面ではありません");
  }
});