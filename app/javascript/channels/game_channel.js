import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  const gameWaiting = document.getElementById('game_waiting');

  if (gameWaiting) {
    const roomId = gameWaiting.dataset.roomId;

    consumer.subscriptions.create(
      { channel: "GameChannel", game_room_id: roomId },
      {
        received(data) {
          if (data.type === "game_start") {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'alert alert-success';
            messageDiv.textContent = data.message;

            const container = document.querySelector('.container');
            if (container) container.prepend(messageDiv);

            setTimeout(() => {
              window.location.href = data.redirect_url;
            }, 0);
          }
        }
      }
    );
  }

  const gamePlay = document.getElementById('game_play');

  if (gamePlay) {
    const roomId = gamePlay.dataset.roomId;
    if (!roomId) return;
    
    consumer.subscriptions.create(
      { channel: "GameChannel", room_id: roomId },
      {
        received(data) {
          if (data.type === "game_finished") {
            const participantId = document.querySelector('[data-participant-id]')?.dataset.participantId;
            const isHost = document.querySelector('[data-is-host="true"]');
            
            let redirectUrl;
            if (isHost) {
              redirectUrl = `/game_rooms/${roomId}/game_play/overall_result`;
            } else if (participantId) {
              redirectUrl = `/game_rooms/${roomId}/participants/${participantId}/personal_result`;
            } else {
              return;
            }

            alert(data.message);
            setTimeout(() => {
              window.location.href = redirectUrl;
            }, 1000);
          }
        }
      }
    );
  }
});