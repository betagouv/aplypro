// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";

document.addEventListener("turbo:load", () => {
  const homeCharts = document.getElementById("home_charts");
  if (homeCharts) {
    Turbo.visit(window.location.href, { frame: "home_charts" });
  }
});
