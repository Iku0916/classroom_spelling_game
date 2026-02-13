document.addEventListener("DOMContentLoaded", () => {
  const slides = document.querySelectorAll(".slide");
  const nextBtns = document.querySelectorAll(".next-btn");
  let current = 0;

  nextBtns.forEach(btn => {
    btn.addEventListener("click", () => {
      slides[current].classList.remove("active");
      current++;
      if (current >= slides.length) current = slides.length - 1; // 最後で止める
      slides[current].classList.add("active");
    });
  });

  const startBtn = document.getElementById("start-btn");
  if(startBtn){
    startBtn.addEventListener("click", () => {
      window.location.href = "/"; // ホームや任意のページに変更
    });
  }
});
