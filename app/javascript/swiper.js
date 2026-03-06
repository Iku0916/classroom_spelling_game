const initSwiper = () => {
  if (window.mySwiperInstance) {
    window.mySwiperInstance.destroy(true, true);
    window.mySwiperInstance = undefined;
  }

  const swiperEl = document.querySelector(".mySwiper");
  if (!swiperEl || typeof Swiper === 'undefined') return;

  window.mySwiperInstance = new Swiper(".mySwiper", {
    grabCursor: true,
    centeredSlides: true,
    slidesPerView: 1,
    spaceBetween: 20,
    autoplay: { delay: 4000, disableOnInteraction: false },
    pagination: { el: ".swiper-pagination", clickable: true }
  });
};

document.addEventListener('turbo:load', initSwiper);
document.addEventListener('turbo:render', initSwiper);