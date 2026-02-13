document.addEventListener("DOMContentLoaded", () => {
  const slides = document.querySelectorAll(".slide");
  const nextBtns = document.querySelectorAll(".next-btn");
  let current = 0;

  nextBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      slides[current].classList.remove("active");
      current++;
      if (current >= slides.length) current = slides.length - 1;
      slides[current].classList.add("active");
    });
  });

  const startBtn = document.getElementById("start-btn");
  if (startBtn) {  // null チェック必須！
    startBtn.addEventListener("click", () => {
      fetch("/onboarding/complete", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      }).then(() => {
        window.location.href = "/";
      });
    });
  }
});

const helpBtn = document.getElementById("help-btn");
if(helpBtn){
  helpBtn.addEventListener("click", () => {
    window.location.href = "/onboarding";
  });
}