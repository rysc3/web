document.addEventListener('DOMContentLoaded', function() {
  setInterval(refreshData, 1000); // Refresh data every second

  function refreshData() {
    fetch('/status/data') // Assuming a route '/status/data' is defined in your routes.rb
      .then(response => response.json())
      .then(data => updatePage(data))
      .catch(error => console.error('Error:', error));
  }

  function updatePage(data) {
    if (data.hostname && data.system_time && data.nodes) {
      document.querySelector('#hostname').textContent = data.hostname;
      document.querySelector('#system-time').textContent = data.system_time;
      document.querySelector('.nodes').innerHTML = data.nodes.map(node => `<div class="node">${node}</div>`).join('');
    }
  }
});
