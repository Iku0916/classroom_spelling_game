import consumer from "channels/consumer"

document.addEventListener('DOMContentLoaded', () => {
  console.log('=== game_room.js 読み込み完了 ===');
  
  const gameRoomData = document.getElementById('game-room-data');
  
  // ✅ game-room-dataが存在しない場合は処理を終了(show.html.erb以外のページでエラーを防ぐ)
  if (!gameRoomData) {
    console.log('ℹ️ game-room-dataが見つかりません。このページではGameChannelは動作しません。');
    return;
  }
  
  const gameRoomId = gameRoomData.dataset.gameRoomId;
  
  console.log('🎮 ゲームルームID:', gameRoomId);
  
  // ✅ GameChannelに接続
  const subscription = consumer.subscriptions.create(
    { channel: 'GameChannel', game_room_id: gameRoomId },
    {
      connected() {
        console.log('✅ GameChannel connected (show)');
      },
      
      disconnected() {
        console.log('❌ GameChannel disconnected');
      },
      
      received(data) {
        console.log('📩 データ受信 (show):', data);
        
        // ✅ 参加者が追加されたとき
        if (data.type === 'participant_joined') {
          handleParticipantJoined(data);
        }
      }
    }
  );
});

// ✅ 参加者が追加されたときの処理
function handleParticipantJoined(data) {
  console.log('👤 新しい参加者:', data.participant.nickname);
  
  // 参加人数を更新
  const countElement = document.getElementById('participants-count');
  if (countElement) {
    countElement.textContent = data.participants_count;
    console.log('✅ 参加人数を更新:', data.participants_count);
  }
  
  // 参加者一覧に追加
  const participantsList = document.getElementById('participants-items');
  if (participantsList) {
    const newParticipant = document.createElement('li');
    newParticipant.dataset.participantId = data.participant.id;
    newParticipant.textContent = data.participant.nickname;
    
    newParticipant.classList.add('nickname-tag');

    participantsList.appendChild(newParticipant);
    console.log('✅ 参加者一覧に追加:', data.participant.nickname);
  }
}
