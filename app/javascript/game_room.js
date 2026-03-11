import consumer from "channels/consumer"

document.addEventListener('DOMContentLoaded', () => {
  const gameRoomData = document.getElementById('game-room-data');
  if (!gameRoomData) return;
  
  const gameRoomId = gameRoomData.dataset.gameRoomId;

  consumer.subscriptions.create(
    { channel: 'GameChannel', game_room_id: gameRoomId },
    {
      received(data) {
        if (data.type === 'participant_joined') {
          handleParticipantJoined(data);
        }
      }
    }
  );
});

function handleParticipantJoined(data) {
  const countElement = document.getElementById('participants-count');
  if (countElement) {
    countElement.textContent = data.participants_count;
  }
  
  const participantsList = document.getElementById('participants-items');
  if (participantsList) {
    const newParticipant = document.createElement('li');
    newParticipant.dataset.participantId = data.participant.id;
    newParticipant.textContent = data.participant.nickname;
    newParticipant.classList.add('nickname-tag');

    participantsList.appendChild(newParticipant);
  }
}