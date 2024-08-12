//= require jquery3
//= require popper
//= require bootstrap

import "bootstrap";

document.addEventListener("turbolinks:load", function() {
  const sideMenu = document.getElementById("side-menu");
  const menuButton = document.getElementById("menu-button");
  const closeButton = document.querySelector(".close-button");

  menuButton.addEventListener("click", function() {
    sideMenu.style.width = "250px"; // Open the side menu
    menuButton.setAttribute("aria-expanded", "true");
  });

  closeButton.addEventListener("click", function() {
    sideMenu.style.width = "0"; // Close the side menu
    menuButton.setAttribute("aria-expanded", "false");
  });

  // Optional: close the menu if the user clicks outside of it
  window.addEventListener("click", function(event) {
    if (event.target === sideMenu) {
      sideMenu.style.width = "0";
      menuButton.setAttribute("aria-expanded", "false");
    }
  });
});