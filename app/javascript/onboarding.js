document.addEventListener("turbo:load", () => {
  const slides = document.querySelectorAll(".slide");
  const nextBtns = document.querySelectorAll(".next-btn");
  let current = 0;

  nextBtns.forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      slides[current].classList.remove("active");
      current++;
      if (current >= slides.length) current = slides.length - 1;
      slides[current].classList.add("active");
    });
  });

  const startBtn = document.getElementById("start-btn");
  if (startBtn) {
    startBtn.addEventListener("click", (e) => {
      e.preventDefault();
      
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

  const helpBtn = document.getElementById("help-btn");
  if (helpBtn) {
    helpBtn.addEventListener("click", (e) => {
      e.preventDefault();
      window.location.href = "/onboarding?force=true"; 
    });
  }
});