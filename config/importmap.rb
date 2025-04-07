# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.8.5/+esm", preload: false
pin "controllers", preload: true
pin "controllers/index", preload: true
pin "controllers/application", preload: true
pin "controllers/map_controller", preload: false
pin "controllers/academic_map_controller", preload: false
pin "leaflet", to: "https://ga.jspm.io/npm:leaflet@1.9.4/dist/leaflet.js", preload: false
pin "leaflet-css", to: "https://ga.jspm.io/npm:leaflet-css@0.1.0/dist/leaflet.css.min.js", preload: false
