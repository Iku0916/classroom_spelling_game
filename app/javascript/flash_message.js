const runFlashFade = () => {
  console.log("Flash logic starting...");
  const flashes = document.querySelectorAll(".flash");
  
  flashes.forEach(flash => {
    setTimeout(() => {
      flash.classList.add("fade-out");
      flash.addEventListener("transitionend", () => {
        flash.remove();
      });
    }, 4000);
  });
};

document.addEventListener("DOMContentLoaded", runFlashFade);
document.addEventListener("turbo:load", runFlashFade);