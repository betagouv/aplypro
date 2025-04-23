# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.8.5/+esm", preload: false
pin "d3-tile", to: "https://cdn.jsdelivr.net/npm/d3-tile@1/+esm", preload: false
pin "utils/map_utils", preload: false
pin_all_from "app/javascript/controllers", under: "controllers"
