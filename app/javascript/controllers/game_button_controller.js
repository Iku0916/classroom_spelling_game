import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="game-button"
export default class extends Controller {
  connect() {const button = document.getElementById("button")
  console.log('button:', button);

    if (button) {
      button.addEventListener("click", () => {
      const waitingElement = document.getElementById("game_waiting");
      console.log(waitingElement);

      const roomId = waitingElement.dataset.roomId;
      console.log(roomId);
      })
    }
  }