//= require jquery3
//= require popper
//= require bootstrap

import "bootstrap";

const images = [
  asset_path('app/assets/images/home-loop/profile.jpg'),
  asset_path('app/assets/images/home-loop/setup-background.jpg'),
];

document.addEventListener("DOMContentLoaded", function() {

  let currentIndex = 0;
  const heroSection = document.getElementById("hero-section");

  function changeBackgroundImage() {
    heroSection.style.backgroundImage = `url(${images[currentIndex]})`;
    currentIndex = (currentIndex + 1) % images.length;
  }

  setInterval(changeBackgroundImage, 5000); // Change every 5 seconds

  // Initial call to set the first image
  changeBackgroundImage();
});
