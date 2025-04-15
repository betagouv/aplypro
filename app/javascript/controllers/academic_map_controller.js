import { Controller } from "@hotwired/stimulus"
import { mapColors, etabMarkerScale, etabMarkerColor, getAcademyGeoJson, ACADEMIES } from "utils/map_utils"

export default class extends Controller {
  static values = {
    highlightColor: { type: String, default: mapColors.lightGreen },
    panDuration: { type: Number, default: 750 },
    academyStrokeColor: { type: String, default: mapColors.normalBlue }
  }

  async connect() {
    this.d3 = await import("d3")
    this.d3Tile = await import("d3-tile")

    try {
      this.selectedAcademy = parseInt(this.element.dataset.selectedAcademyValue)
      this.parsedEstablishments = JSON.parse(this.element.dataset.establishmentsForAcademy)
      this.parsedNbSchoolings = JSON.parse(this.element.dataset.nbSchoolingsPerEstablishments)
      this.parsedAmounts = JSON.parse(this.element.dataset.amountsPerEstablishments)

      this.maxNbSchoolings = Math.max(...Object.values(this.parsedNbSchoolings))
      this.maxAmount = Math.max(...Object.values(this.parsedAmounts))

      this.createMap()
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
    this.svg = null
    this.width = null
    this.height = null
    this.currentTransform = null
    this.zoom = null
  }

  zoomed(event) {
      this.currentTransform = event.transform

      this.projection
          .scale(event.transform.k / (2 * Math.PI))
          .translate([event.transform.x, event.transform.y])

      const tiles = this.tileLayout(event.transform)

      this.tileLayer.selectAll("image")
          .data(tiles, d => d)
          .join("image")
          .attr("xlink:href", d => `https://a.tile.openstreetmap.org/${d[2]}/${d[0]}/${d[1]}.png`)
          .attr("x", ([x]) => (x + tiles.translate[0]) * tiles.scale)
          .attr("y", ([,y]) => (y + tiles.translate[1]) * tiles.scale)
          .attr("width", tiles.scale)
          .attr("height", tiles.scale)
          .style("filter", "saturate(0.3)")

      this.academyLayer.selectAll("path")
          .attr("d", this.path)

      this.academyLayer.selectAll("circle")
          .attr("cx", d => this.projection(d.geometry.coordinates)[0])
          .attr("cy", d => this.projection(d.geometry.coordinates)[1])
  }

  createMap() {
    const containerId = 'map-container'
    const container = document.getElementById(containerId)

    if (!container || container.hasAttribute('data-initialized')) return

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    this.width = container.offsetWidth
    this.height = 700

    this.svg = this.d3.select("#" + containerId)
        .append("svg")
        .attr("width", this.width)
        .attr("height", this.height)

    this.tileLayer = this.svg.append("g").attr("id", "tile-layer")
    this.academyLayer = this.svg.append("g").attr("id", "academy-layer")

    this.projection = this.d3.geoMercator()
        .scale(1)
        .translate([0, 0])

    this.tileLayout = this.d3Tile.tile().size([this.width, this.height])

    this.path = this.d3.geoPath().projection(this.projection)

    this.createAcademyPath().then(initialTransform => {
      this.zoom = this.d3.zoom()
          .scaleExtent([1, Infinity])
          .on("zoom", this.zoomed.bind(this))

      this.currentTransform = initialTransform

      this.svg.call(this.zoom)
          .call(this.zoom.transform, initialTransform)

      this.zoom.scaleExtent([initialTransform.k * 0.8, Infinity])

      this.createEtabMarkers()
    })
  }

  async createAcademyPath() {
    try {
      const geojson = await this.d3.json(getAcademyGeoJson(this.selectedAcademy))

      const academyCode = ACADEMIES[this.selectedAcademy]
      if (academyCode) {
        const academyName = academyCode
          .slice(3)
          .replace(/_/g, ' ')
          .toLowerCase()
          .split(' ')
          .map(word => word.charAt(0).toUpperCase() + word.slice(1))
          .join(' ')

        const h2Element = document.querySelector('h2')
        if (h2Element) {
          h2Element.textContent = `Académie ${this.selectedAcademy} : ${academyName}`
        }
      }

      const [[x0, y0], [x1, y1]] = this.d3.geoPath().projection(this.projection).bounds(geojson)

      const dx = x1 - x0
      const dy = y1 - y0
      const cx = (x0 + x1) / 2
      const cy = (y0 + y1) / 2

      const scale = 0.95 / Math.max(dx / this.width, dy / this.height)
      const translate = [this.width / 2 - scale * cx, this.height / 2 - scale * cy]

      this.projection
          .scale(scale)
          .translate(translate)

      this.academyLayer.selectAll("path")
          .data(geojson.features)
          .enter()
          .append("path")
          .attr("stroke", this.academyStrokeColorValue)
          .attr("fill", "none")
          .attr("stroke-width", 2)
          .attr("d", this.path)

      return this.d3.zoomIdentity
          .translate(translate[0], translate[1])
          .scale(scale * 2 * Math.PI)
    } catch (error) {
      console.error("Error loading the geo file:", error)
    }
  }

  createEtabMarkers() {
    const d3 = this.d3
    d3.json("/data/ETABLISSEMENTS_FRANCE.geojson").then((geojson) => {
      const tooltip = d3.select("#map-container")
          .append("div")
          .attr("class", "tooltip")
          .style("position", "absolute")
          .style("background", "white")
          .style("padding", "5px")
          .style("border-radius", "5px")
          .style("pointer-events", "none")
          .style("display", "none")
          .style("z-index", "1000")
          .style("box-shadow", "0 2px 4px rgba(0,0,0,0.2)")

      this.academyLayer.selectAll("circle")
          .data(geojson.features.filter(d => this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)))
          .enter()
          .append("circle")
          .filter(d => d.geometry && d.geometry.coordinates)
          .attr("id", d => `marker-${d.properties.Code_UAI}`)
          .attr("cx", d => this.projection(d.geometry.coordinates)[0])
          .attr("cy", d => this.projection(d.geometry.coordinates)[1])
          .attr("r", d => etabMarkerScale(d3, this.parsedNbSchoolings[d.properties.Code_UAI], this.maxNbSchoolings))
          .attr("fill", d => etabMarkerColor(d3, this.parsedAmounts[d.properties.Code_UAI], this.maxAmount))
          .attr("stroke", "black")
          .attr("stroke-width", 1)
          .attr("data-longitude", d => d.geometry.coordinates[0])
          .attr("data-latitude", d => d.geometry.coordinates[1])
          .on("mouseover", (event, d) => this.mouseOver(event, d, tooltip))
          .on("mouseout", (event, d) => this.mouseOut(event, d, tooltip))
          .on("click", (event, d) => {
            this.highlightRow(d.properties.Code_UAI)
          })
    }).catch((error) => {
      console.error("Error loading the geo file:", error)
    })
  }

  highlightRow(uai) {
    document.querySelectorAll("tr.selected").forEach(tr => {
      tr.classList.remove("selected")
      tr.style.backgroundColor = ''
    })

    const row = document.querySelector(`tr.academic-map[data-uai="${uai}"]`)
    if (row) {
      row.classList.add("selected")
      row.style.backgroundColor = this.highlightColorValue
      row.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
    }
  }

  panToMarker(longitude, latitude) {
    const [x, y] = this.projection([longitude, latitude]);

    const centerX = this.width / 2;
    const centerY = this.height / 2;

    const dx = centerX - x;
    const dy = centerY - y;

    const newTransform = this.d3.zoomIdentity
        .translate(this.currentTransform.x + dx, this.currentTransform.y + dy)
        .scale(this.currentTransform.k);
    this.svg
        .transition()
        .duration(this.panDurationValue)
        .call(this.zoom.transform, newTransform);
  }

  selectEstablishment(event) {
    const uai = event.currentTarget.dataset.uai
    const marker = document.querySelector(`#marker-${uai}`)

    if (marker) {
      const longitude = parseFloat(marker.getAttribute("data-longitude"))
      const latitude = parseFloat(marker.getAttribute("data-latitude"))

      this.panToMarker(longitude, latitude)

      this.d3.select(marker)
          .interrupt()

      const originalColor = etabMarkerColor(this.d3, this.parsedAmounts[uai], this.maxAmount)

      this.highlightRow(uai)

      this.d3.select(marker)
          .transition()
          .duration(200)
          .attr("fill", this.highlightColorValue)
          .transition()
          .duration(200)
          .delay(500)
          .attr("fill", originalColor)
    }
  }

  mouseOver(event, d, tooltip) {
    const e = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)

    this.d3.select(event.currentTarget)
        .transition()
        .duration(200)
        .attr("fill", this.highlightColorValue)

    tooltip
        .style("left", (event.pageX + 10) + "px")
        .style("top", (event.pageY - 10) + "px")
        .style("display", "block")
        .html(`${e.uai} - ${e.name}<br>
             ${e.address_line1}, ${e.city}, ${e.postal_code}<br>
             Nombre de scolarités : ${this.parsedNbSchoolings[e.uai]}<br>
             Montant total payé : ${this.parsedAmounts[e.uai]} €`)
  }

  mouseOut(event, d, tooltip) {
    this.d3.select(event.currentTarget)
        .transition()
        .duration(200)
        .attr("fill", etabMarkerColor(this.d3, this.parsedAmounts[d.properties.Code_UAI], this.maxAmount))

    tooltip.style("display", "none")
  }
}
