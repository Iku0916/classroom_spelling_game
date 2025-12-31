import consumer from "./consumer"

document.addEventListener('turbo:load', () => {
  const gameWaiting = document.getElementById('game_waiting');

  if (!gameWaiting) {
    console.log("=== game_waiting要素が見つかりません ===");
    return;
  }

  console.log("=== game_waiting要素が見つかりました ===");

  const roomId = gameWaiting.dataset.roomId;
  console.log(`=== サブスクライブ開始: room ${roomId} ===`);

  consumer.subscriptions.create(
    { channel: "GameChannel", room_id: roomId },
    {
      connected() {
        console.log("=== WebSocket接続成功 ===");
      },

      disconnected() {
        console.log("=== WebSocket切断 ===");
      },

      received(data) {
        console.log("=== データ受信 ===", data);

        if (data.type === "game_start") {
          console.log("=== game_startイベントを検知 ===");

          const messageDiv = document.createElement('div');
          messageDiv.className = 'alert alert-success';
          messageDiv.textContent = data.message;

          const container = document.querySelector('.container');
          if (container) {
            container.prepend(messageDiv);
          }

          setTimeout(() => {
            console.log("=== リダイレクト実行 ===", data.redirect_url);
            window.location.href = data.redirect_url;
          }, 2000);
        }
      }
    }
  );
});