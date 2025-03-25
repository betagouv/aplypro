// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";

let hasRefreshedHomeCharts = false;

document.addEventListener("turbo:load", () => {
  const homeCharts = document.getElementById("home_charts");
  if (homeCharts && !hasRefreshedHomeCharts) {
    hasRefreshedHomeCharts = true;
    Turbo.visit(window.location.href, { frame: "home_charts" });
  }
});
