// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// confit.assets.debug = true
document.addEventListener("DOMContentLoaded", function () {
  const collapseButton = document.getElementById("collapseButton");
  const collapseExample = document.getElementById("collapseExample");

  collapseButton.addEventListener("click", function () {
    collapseExample.classList.toggle("show");
  });
});
