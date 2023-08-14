document.addEventListener("DOMContentLoaded", function () {
  // Initialize the Bootstrap Carousel
  const carouselElement = document.getElementById("carouselExampleCaptions");
  const carousel = new bootstrap.Carousel(carouselElement, {
    interval: 3000, // Set the interval for carousel auto-sliding (in milliseconds)
  });

  // Handle modal behavior when clicking on carousel images
  const carouselItems = document.querySelectorAll(".carousel-item");
  carouselItems.forEach((item, index) => {
    const imageLink = item.querySelector("a[data-bs-toggle='modal']");
    if (imageLink) {
      imageLink.addEventListener("click", function (event) {
        event.preventDefault(); // Prevent default link behavior

        // Get the target modal and its image
        const targetModalId = imageLink.getAttribute("data-bs-target");
        const modal = new bootstrap.Modal(document.querySelector(targetModalId));
        const image = modal._element.querySelector("img");

        // Set the modal size to the image's exact dimensions
        const imageWidth = 1500; // Set the desired width
        const imageHeight = 500; // Set the desired height
        image.style.width = `${imageWidth}px`;
        image.style.height = `${imageHeight}px`;

        modal.show(); // Show the corresponding modal when image is clicked
      });
    }
  });
});
