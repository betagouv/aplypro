import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  async connect() {
    this.d3 = await import("d3")

    try {
      this.selectedAcademy = parseInt(this.element.dataset.selectedAcademyValue)
      this.initMap()
    } catch (error) {
      console.error("Error parsing data:", error)
    }
  }

  disconnect() {
    const container = document.getElementById('map-container')
    if (container) {
      container.removeAttribute('data-initialized')
      container.innerHTML = ''
    }
  }

  initMap() {
    if (!this.selectedAcademy) {
      console.error("Missing data values")
      return
    }

    const maps = [
      { id: 1, path: '/data/01_PARIS.geojson' },
      { id: 2, path: '/data/02_AIX_MARSEILLE.geojson' },
      { id: 3, path: '/data/03_BESANCON.geojson' },
      { id: 4, path: '/data/04_BORDEAUX.geojson' },
      { id: 6, path: '/data/06_CLERMONT_FERRAND.geojson' },
      { id: 7, path: '/data/07_DIJON.geojson' },
      { id: 8, path: '/data/08_GRENOBLE.geojson' },
      { id: 9, path: '/data/09_LILLE.geojson' },
      { id: 10, path: '/data/10_LYON.geojson' },
      { id: 11, path: '/data/11_MONTPELLIER.geojson' },
      { id: 12, path: '/data/12_NANCY_METZ.geojson' },
      { id: 13, path: '/data/13_POITIERS.geojson' },
      { id: 14, path: '/data/14_RENNES.geojson' },
      { id: 15, path: '/data/15_STRASBOURG.geojson' },
      { id: 16, path: '/data/16_TOULOUSE.geojson' },
      { id: 17, path: '/data/17_NANTES.geojson' },
      { id: 18, path: '/data/18_ORLEANS_TOURS.geojson' },
      { id: 19, path: '/data/19_REIMS.geojson' },
      { id: 20, path: '/data/20_AMIENS.geojson' },
      { id: 22, path: '/data/22_LIMOGES.geojson' },
      { id: 23, path: '/data/23_NICE.geojson' },
      { id: 24, path: '/data/24_CRETEIL.geojson' },
      { id: 25, path: '/data/25_VERSAILLES.geojson' },
      { id: 27, path: '/data/27_CORSE.geojson' },
      { id: 28, path: '/data/28_REUNION.geojson', center: [55.5, -21.1], scale: 10000 },
      { id: 31, path: '/data/31_MARTINIQUE.geojson', center: [-61.0, 14.6], scale: 10000 },
      { id: 32, path: '/data/32_GUADELOUPE.geojson', center: [-61.5, 16.25], scale: 10000 },
      { id: 33, path: '/data/33_GUYANE.geojson', center: [-53.0, 4.0], scale: 1000 },
      { id: 43, path: '/data/43_MAYOTTE.geojson', center: [45.2, -12.8], scale: 15000 },
      { id: 44, path: '/data/44_SAINT_PIERRE_ET_MIQUELON.geojson', center: [-56.3, 47.0], scale: 10000 },
      { id: 70, path: '/data/70_NORMANDIE.geojson' }
    ]

    maps.forEach(map => {
      if(map.id === this.selectedAcademy){
        this.createMap(map.id, map.path, map.center, map.scale)
      }
    })
  }

  createMap(containerId, geoJsonPath, centerCoords, scale) {
    const d3 = this.d3
    const container = document.getElementById(containerId)
    if (!container || container.hasAttribute('data-initialized')) return

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    const width = container.offsetWidth
    const height = 140

    const svg = d3.select("#" + containerId)
      .append("svg")
      .attr("width", width)
      .attr("height", height)

    const g = svg.append("g")

    const projection = d3.geoMercator()
      .center(centerCoords)
      .scale(scale)
      .translate([width / 2, height / 2])

    const path = d3.geoPath()
      .projection(projection)

    d3.json(geoJsonPath).then((geojson) => {
      g.selectAll("path")
        .data(geojson.features)
        .enter()
        .append("path")
        .attr("d", path)
        .attr("opacity", 0.7)
    }).catch((error) => {
      console.error("Error loading the geo file for " + containerId + ":", error)
    })
  }
}
