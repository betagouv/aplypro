import { Controller } from "@hotwired/stimulus"
import { mapColors, etabMarkerScale, etabMarkerColor, getAcademyGeoJson } from "utils/map_utils"

export default class extends Controller {
  static targets = ["mapContainer"]

  static values = {
    highlightColor: { type: String, default: mapColors.lightYellow },
    panDuration: { type: Number, default: 750 },
    academyStrokeColor: { type: String, default: mapColors.normalBlue },
    menjIconPath: { type: String },
    masaIconPath: { type: String }
  }

  initialize() {
    this.svg = null
    this.width = null
    this.height = null
    this.currentTransform = null
    this.zoom = null
    this.academyGeojson = null
    this.menjIconPath = this.element.dataset.menjIconPath
    this.masaIconPath = this.element.dataset.masaIconPath
    this.selectedAcademy = parseInt(this.element.dataset.selectedAcademyValue)
    this.parsedEstablishments = JSON.parse(this.element.dataset.establishmentsForAcademy)
    this.parsedNbSchoolings = JSON.parse(this.element.dataset.nbSchoolingsPerEstablishments)
    this.parsedAmounts = JSON.parse(this.element.dataset.amountsPerEstablishments)
    this.maxNbSchoolings = Math.max(...Object.values(this.parsedNbSchoolings))
    this.bopVisibleStates = { masa: true, menj: true }
  }

  async connect() {
    this.d3 = await import("d3")
    this.d3Tile = await import("d3-tile")

    try {
      this.createMap()
      await this.createMarkerSymbols()
      this.createLegend()
      this.createEtabMarkers()
    } catch (error) {
      console.error("Error during initialization:", error)
    }
  }

  disconnect() {
    this.mapContainerTarget.innerHTML = ''
  }

  createLegend() {
    const legend = this.svg.append("g")
      .attr("class", "legend")
      .attr("transform", `translate(10, ${this.height - 40})`)

    legend.append("rect")
      .attr("width", 200)
      .attr("height", 30)
      .attr("fill", "white")

    const legendItems = [
      { symbol: "#masa", text: "MASA", x: 20, type: "masa" },
      { symbol: "#menj", text: "MENJ", x: 110, type: "menj" }
    ]

    legendItems.forEach(item => {
      const group = legend.append("g")
        .attr("id", `legend-${item.type}`)
        .attr("transform", `translate(${item.x}, 5)`)
        .style("cursor", "pointer")
        .on("click", () => this.toggleBop(item.type))

      group.append("use")
        .attr("href", item.symbol)
        .attr("width", 20)
        .attr("height", 20)
        .attr("x", 0)
        .attr("y", 0)

      group.append("text")
        .attr("x", 25)
        .attr("y", 15)
        .text(item.text)
        .style("font-size", "14px")
    })
  }

  toggleBop(type) {
    this.bopVisibleStates[type] = !this.bopVisibleStates[type]

    this.svg.selectAll(`.marker-${type}`)
      .style("display", this.bopVisibleStates[type] ? "block" : "none")

    this.svg.select(`#legend-${type}`)
      .selectAll("use, text")
      .style("fill", this.bopVisibleStates[type] ? "black" : "#999")
  }

  createMarkerSymbols() {
    const defs = this.svg.append("defs")

    const createSymbolFromIcon = async (iconPath, symbolId) => {
      const svgDoc = await this.d3.svg(iconPath)
      const pathData = svgDoc.querySelector('path').getAttribute('d')
      defs.append("symbol")
        .attr("id", symbolId)
        .attr("viewBox", "0 0 24 24")
        .append("path")
        .attr("d", pathData)
    }

    return Promise.all([
      createSymbolFromIcon(this.masaIconPath, "masa"),
      createSymbolFromIcon(this.menjIconPath, "menj")
    ])
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

    this.academyLayer.selectAll("g.marker")
      .attr("transform", d => {
        const [x, y] = this.projection(d.geometry.coordinates)
        return `translate(${x},${y})`
      })
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

      this.academyLayer.selectAll("g.marker")
        .data(geojson.features.filter(d => this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)))
        .enter()
        .append("g")
        .attr("class", d => {
          const etab = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
          return `marker marker-${etab.ministry === "AGRICULTURE" ? "masa" : "menj"}`
        })
        .filter(d => d.geometry && d.geometry.coordinates)
        .attr("id", d => `marker-${d.properties.Code_UAI}`)
        .attr("transform", d => {
          const [x, y] = this.projection(d.geometry.coordinates)
          return `translate(${x},${y})`
        })
        .each((d, i, nodes) => {
          const etab = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
          const size = etabMarkerScale(d3, this.parsedNbSchoolings[d.properties.Code_UAI], this.maxNbSchoolings, academyBounds)

          d3.select(nodes[i])
            .append("use")
            .attr("href", etab.ministry === "AGRICULTURE" ? "#masa" : "#menj")
            .attr("width", size)
            .attr("height", size)
            .attr("x", -size/2)
            .attr("y", -size/2)
            .attr("fill", etabMarkerColor(d3, d, this.parsedAmounts))
            .attr("stroke", "black")
            .attr("stroke-width", "1")
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
      const markerData = this.d3.select(marker).datum()
      const coordinates = markerData.geometry.coordinates
      this.panToMarker(coordinates[0], coordinates[1])

      this.d3.select(marker).select("use")
        .interrupt()
        .transition()
        .duration(200)
        .attr("stroke", this.highlightColorValue)
        .transition()
        .duration(200)
        .delay(500)
        .attr("stroke", "black")

      this.highlightRow(uai)
    }
  }

  mouseOver(event, d, tooltip) {
    const e = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
    const amounts = this.parsedAmounts[d.properties.Code_UAI]
    const ratio = amounts.payable_amount > 0 ? amounts.paid_amount / amounts.payable_amount : 0

    const progressBarHtml = amounts.payable_amount > 0 ? `
      <div style="
        width: 100%;
        height: 20px;
        background: linear-gradient(to right,
          ${mapColors.normalRed} 0%,
          ${mapColors.normalYellow} 50%,
          ${mapColors.normalGreen} 100%
        );
        border-radius: 4px;
        position: relative;
        margin: 5px 0;
      ">
        <div style="
          position: absolute;
          left: ${ratio * 100}%;
          transform: translateX(-50%);
          width: 3px;
          height: 20px;
          background: black;
        "></div>
      </div>
      <div style="text-align: center;">${(ratio * 100).toFixed(1)}%</div>
    ` : ''

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
        </table>
        ${progressBarHtml}
      `)
  }

  mouseOut(event, d, tooltip) {
    this.d3.select(event.currentTarget).select("use")
      .transition()
      .duration(200)
      .attr("fill", etabMarkerColor(this.d3, d, this.parsedAmounts))
    tooltip.style("display", "none")
  }
}
