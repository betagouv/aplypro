import { Controller } from "@hotwired/stimulus"
import { mapColors, etabMarkerScale, etabMarkerColor, getAcademyGeoJson } from "utils/map_utils"

export default class extends Controller {
  static targets = ["mapContainer"]

  static values = {
    highlightColor: { type: String, default: mapColors.lightGreen },
    panDuration: { type: Number, default: 750 },
    academyStrokeColor: { type: String, default: mapColors.normalBlue },
    agricultureIcon: { type: String, default: "fr-icon-seedling-fill" },
    defaultIcon: { type: String, default: "fr-icon-git-repository-fill" }
  }

  initialize(){
    this.svg = null
    this.width = null
    this.height = null
    this.currentTransform = null
    this.zoom = null
    this.academyGeojson = null
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
      this.createMap()
      this.createLegend()
    } catch (error) {
      console.error("Error parsing data:", error)
    }
  }

  disconnect() {
    this.mapContainerTarget.innerHTML = ''
  }

  createLegend() {
    const legend = this.svg.append("g")
      .attr("class", "legend")
      .attr("transform", `translate(10, ${this.height - 40})`)

    const legendBackground = legend.append("rect")
      .attr("width", 200)
      .attr("height", 30)
      .attr("fill", "white")

    const legendItems = [
      { icon: this.agricultureIconValue, text: "MASA", x: 20 },
      { icon: this.defaultIconValue, text: "MENJ", x: 110 }
    ]

    legendItems.forEach(item => {
      const group = legend.append("g")
        .attr("transform", `translate(${item.x}, 5)`)

      const foreignObject = group.append("foreignObject")
        .attr("width", 30)
        .attr("height", 20)

      foreignObject.html(`<i class="${item.icon}" style="font-size: 16px;"></i>`)

      group.append("text")
        .attr("x", 25)
        .attr("y", 15)
        .text(item.text)
        .style("font-size", "14px")
    })
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

    this.academyLayer.selectAll("path")
      .attr("d", this.path)

    this.academyLayer.selectAll("foreignObject")
      .attr("x", d => this.projection(d.geometry.coordinates)[0])
      .attr("y", d => this.projection(d.geometry.coordinates)[1])
  }

  createMap() {
    this.width = this.mapContainerTarget.offsetWidth
    const tableContainer = document.querySelector('.establishments-table-container')
    const maxHeight = tableContainer ?
      parseInt(window.getComputedStyle(tableContainer).maxHeight) :
      700
    this.height = maxHeight

    this.svg = this.d3.select(this.mapContainerTarget)
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
      this.academyGeojson = await this.d3.json(getAcademyGeoJson(this.selectedAcademy))
      const h2Element = document.querySelector('h2')
      if (h2Element && this.academyGeojson.name) {
        h2Element.textContent = `Académie ${this.selectedAcademy} : ${this.academyGeojson.name}`
      }

      const [[x0, y0], [x1, y1]] = this.d3.geoPath().projection(this.projection).bounds(this.academyGeojson)
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
        .data(this.academyGeojson.features)
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
    d3.json("/data/etablissements.geojson").then((geojson) => {
      const tooltip = d3.select(this.mapContainerTarget)
              .append("div")
              .attr("class", "tooltip")

      const academyBounds = this.path.bounds(this.academyGeojson)

      this.academyLayer.selectAll("foreignObject")
        .data(geojson.features.filter(d => this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)))
        .enter()
        .append("foreignObject")
        .filter(d => d.geometry && d.geometry.coordinates)
        .attr("id", d => `marker-${d.properties.Code_UAI}`)
        .attr("width", d => etabMarkerScale(
          d3,
          this.parsedNbSchoolings[d.properties.Code_UAI],
          this.maxNbSchoolings,
          academyBounds
        ) * 2)
        .attr("height", d => etabMarkerScale(
          d3,
          this.parsedNbSchoolings[d.properties.Code_UAI],
          this.maxNbSchoolings,
          academyBounds
        ) * 2)
        .attr("x", d => this.projection(d.geometry.coordinates)[0])
        .attr("y", d => this.projection(d.geometry.coordinates)[1])
        .attr("data-longitude", d => d.geometry.coordinates[0])
        .attr("data-latitude", d => d.geometry.coordinates[1])
        .html(d => {
          const etab = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
          const iconClass = etab.ministry === "AGRICULTURE" ? this.agricultureIconValue : this.defaultIconValue
          return `<i class="${iconClass}" style="color: ${etabMarkerColor(d3, d, this.parsedAmounts)}"></i>`
        })
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
      row.classList.add('scroll-margin-top')
      row.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
    }
  }

  panToMarker(longitude, latitude) {
    const [x, y] = this.projection([longitude, latitude])
    const centerX = this.width / 2
    const centerY = this.height / 2
    const dx = centerX - x
    const dy = centerY - y

    const newTransform = this.d3.zoomIdentity
      .translate(this.currentTransform.x + dx, this.currentTransform.y + dy)
      .scale(this.currentTransform.k)

    this.svg
      .transition()
      .duration(this.panDurationValue)
      .call(this.zoom.transform, newTransform)
  }

  selectEstablishment(event) {
    const uai = event.currentTarget.dataset.uai
    const marker = document.querySelector(`#marker-${uai}`)
    if (marker) {
      const longitude = parseFloat(marker.getAttribute("data-longitude"))
      const latitude = parseFloat(marker.getAttribute("data-latitude"))
      this.panToMarker(longitude, latitude)

      this.d3.select(marker).select("i")
        .interrupt()

      this.highlightRow(uai)

      this.d3.select(marker).select("i")
        .transition()
        .duration(200)
        .style("color", this.highlightColorValue)
        .transition()
        .duration(200)
        .delay(500)
        .style("color", d => etabMarkerColor(this.d3, d, this.parsedAmounts))
    }
  }

  mouseOver(event, d, tooltip) {
    const e = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
    const amounts = this.parsedAmounts[d.properties.Code_UAI]

    const ratioHtml = amounts.payable_amount > 0
      ? `<tr><td>Ratio :</td><td>${((amounts.paid_amount / amounts.payable_amount) * 100).toFixed(1)}%</td></tr>`
      : ''

    tooltip
      .style("display", "block")
      .style("left", (event.pageX + 10) + "px")
      .style("top", (event.pageY + 10) + "px")
      .html(`
        <strong>${e.uai} - ${e.name}</strong><br>
        ${e.address_line1}, ${e.city}, ${e.postal_code}<br><br>
        <table>
          <tr><td>Nombre de scolarités :</td><td>${this.parsedNbSchoolings[e.uai]}</td></tr>
          <tr><td>Montant payable :</td><td>${amounts.payable_amount} €</td></tr>
          <tr><td>Montant payé :</td><td>${amounts.paid_amount} €</td></tr>
          ${ratioHtml}
        </table>
      `)
  }

  mouseOut(event, d, tooltip) {
    this.d3.select(event.currentTarget).select("i")
      .transition()
      .duration(200)
      .style("color", etabMarkerColor(this.d3, d, this.parsedAmounts))
    tooltip.style("display", "none")
  }
}
