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
      { id: 'map-1', path: '/data/01_PARIS.geojson' },
      { id: 'map-2', path: '/data/02_AIX_MARSEILLE.geojson' },
      { id: 'map-3', path: '/data/03_BESANCON.geojson' },
      { id: 'map-4', path: '/data/04_BORDEAUX.geojson' },
      { id: 'map-6', path: '/data/06_CLERMONT_FERRAND.geojson' },
      { id: 'map-7', path: '/data/07_DIJON.geojson' },
      { id: 'map-8', path: '/data/08_GRENOBLE.geojson' },
      { id: 'map-9', path: '/data/09_LILLE.geojson' },
      { id: 'map-10', path: '/data/10_LYON.geojson' },
      { id: 'map-11', path: '/data/11_MONTPELLIER.geojson' },
      { id: 'map-12', path: '/data/12_NANCY_METZ.geojson' },
      { id: 'map-13', path: '/data/13_POITIERS.geojson' },
      { id: 'map-14', path: '/data/14_RENNES.geojson' },
      { id: 'map-15', path: '/data/15_STRASBOURG.geojson' },
      { id: 'map-16', path: '/data/16_TOULOUSE.geojson' },
      { id: 'map-17', path: '/data/17_NANTES.geojson' },
      { id: 'map-18', path: '/data/18_ORLEANS_TOURS.geojson' },
      { id: 'map-19', path: '/data/19_REIMS.geojson' },
      { id: 'map-20', path: '/data/20_AMIENS.geojson' },
      { id: 'map-22', path: '/data/22_LIMOGES.geojson' },
      { id: 'map-23', path: '/data/23_NICE.geojson' },
      { id: 'map-24', path: '/data/24_CRETEIL.geojson' },
      { id: 'map-25', path: '/data/25_VERSAILLES.geojson' },
      { id: 'map-27', path: '/data/27_CORSE.geojson' },
      { id: 'map-28', path: '/data/28_REUNION.geojson' },
      { id: 'map-31', path: '/data/31_MARTINIQUE.geojson' },
      { id: 'map-32', path: '/data/32_GUADELOUPE.geojson' },
      { id: 'map-33', path: '/data/33_GUYANE.geojson' },
      { id: 'map-43', path: '/data/43_MAYOTTE.geojson' },
      { id: 'map-44', path: '/data/44_SAINT_PIERRE_ET_MIQUELON.geojson' },
      { id: 'map-70', path: '/data/70_NORMANDIE.geojson' }
    ]

    maps.forEach(map => {
      if(map.id === 'map-' + this.selectedAcademy){
        return this.createMap(map.path, map.center, map.scale)
      }
    })
  }

  createMap(geoJsonPath) {
    const d3 = this.d3
    const container = document.getElementById('map-container')

    if (!container || container.hasAttribute('data-initialized')) {
      console.error("Missing data-initialized attribute")
      return
    }

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    const width = container.offsetWidth
    const height = 540

    const svg = d3.select("#map-container")
      .append("svg")
      .attr("width", width)
      .attr("height", height)

    const g = svg.append("g")

    d3.json(geoJsonPath).then((geojson) => {
      const projection = d3.geoMercator().fitSize([width, height], geojson)

      const path = d3.geoPath().projection(projection)

      g.selectAll("path")
        .data(geojson.features)
        .enter()
        .append("path")
        .attr("d", path)
        .attr("opacity", 0.7)
    }).catch((error) => {
      console.error("Error loading the geo file:", error)
    })
  }
}
