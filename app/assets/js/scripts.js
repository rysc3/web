/**
 * This is where extra scripts can go to override main.js
 */
// window.addEventListener('DOMContentLoaded', event => {
//   const button = document.querySelector('.navbar-toggler');
//   const menu = document.querySelector('#navbarSupportedContent');

//   button.addEventListener('click', () => {
//     const expanded = button.getAttribute('aria-expanded');
//     const newExpanded = expanded === 'true' ? 'false' : 'true';
//     button.setAttribute('aria-expanded', newExpanded);
//     menu.classList.toggle('show');
//     menu.classList.toggle('collapse');
//   });
// });
window.addEventListener('DOMContentLoaded', event => {
  const listHoursArray = document.body.querySelectorAll('.list-hours li');
  listHoursArray[new Date().getDay()].classList.add(('today'));
})