import { Controller } from "@hotwired/stimulus"
import {
  mapColors,
  etabMarkerScale,
  etabMarkerColor,
  getAcademyGeoJson,
  createMapLegend,
  updateLegendAppearance,
  toggleBopVisibility,
  createProgressBarHTML,
  getEstablishmentSymbolId
} from "utils/map_utils"

export default class extends Controller {
  static targets = ["mapContainer"]

  static values = {
    highlightColor: { type: String, default: mapColors.lightYellow },
    panDuration: { type: Number, default: 750 },
    academyStrokeColor: { type: String, default: mapColors.normalBlue },
    menjIconPath: { type: String },
    masaIconPath: { type: String },
    merIconPath: { type: String },
    justiceIconPath: { type: String },
    defenseIconPath: { type: String },
    santeIconPath: { type: String },
    enpuIconPath: { type: String },
    enprIconPath: { type: String }
  }

  initialize() {
    this.arrowDown = ' &#9660;'
    this.arrowUp = ' &#9650;'
    this.svg = null
    this.width = null
    this.height = null
    this.currentTransform = null
    this.zoom = null
    this.academyGeojson = null
    this.menjIconPath = this.element.dataset.menIconPath
    this.masaIconPath = this.element.dataset.agriIconPath
    this.merIconPath = this.element.dataset.merIconPath
    this.justiceIconPath = this.element.dataset.justiceIconPath
    this.defenseIconPath = this.element.dataset.defenseIconPath
    this.santeIconPath = this.element.dataset.santeIconPath
    this.enpuIconPath = this.element.dataset.enpuIconPath
    this.enprIconPath = this.element.dataset.enprIconPath
    this.selectedAcademy = parseInt(this.element.dataset.selectedAcademyValue)
    this.establishments = JSON.parse(this.element.dataset.establishmentsData)
    this.maxNbSchoolings = Math.max(...Object.values(this.establishments).map(e => e.schooling_count))
    this.bopVisibleStates = {
      masa: true,
      menj: true,
      mer: true,
      justice: true,
      defense: true,
      sante: true,
      enpu: true,
      enpr: true
    }
  }

  async connect() {
    if (!this.hasMapContainerTarget) {
      console.warn("MapContainer target not found, skipping map initialization")
      return
    }

    this.d3 = await import("d3")
    this.d3Tile = await import("d3-tile")

    try {
      this.createMap()
      await this.createMarkerSymbols()
      this.createLegend()
      this.createEtabMarkers()
      this.setupTableSorting()
    } catch (error) {
      console.error("Error during initialization:", error)
    }
  }

  disconnect() {
    if (this.hasMapContainerTarget) {
      this.mapContainerTarget.innerHTML = ''
    }
  }

  createLegend() {
    createMapLegend(this.svg, this.height, (type) => this.toggleBop(type))
  }

  toggleBop(type) {
    this.bopVisibleStates = toggleBopVisibility(
      this.academyLayer,
      this.bopVisibleStates,
      type,
      this.establishments
    )

    updateLegendAppearance(this.svg, type, this.bopVisibleStates[type])
  }

  createMarkerSymbols() {
    const defs = this.svg.append("defs")

    const createSymbolFromIcon = async (iconPath, symbolId) => {
      if (!iconPath) return Promise.resolve()
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
      createSymbolFromIcon(this.menjIconPath, "men"),
      createSymbolFromIcon(this.merIconPath, "mer"),
      createSymbolFromIcon(this.justiceIconPath, "justice"),
      createSymbolFromIcon(this.defenseIconPath, "défense"),
      createSymbolFromIcon(this.santeIconPath, "santé"),
      createSymbolFromIcon(this.enpuIconPath, "enpu"),
      createSymbolFromIcon(this.enprIconPath, "enpr")
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
        .data(geojson.features.filter(d => this.establishments[d.properties.Code_UAI]))
        .enter()
        .append("g")
        .attr("class", "marker")
        .filter(d => d.geometry && d.geometry.coordinates)
        .attr("id", d => `marker-${d.properties.Code_UAI}`)
        .attr("transform", d => {
          const [x, y] = this.projection(d.geometry.coordinates)
          return `translate(${x},${y})`
        })
        .each((d, i, nodes) => {
          const etab = this.establishments[d.properties.Code_UAI]
          const size = etabMarkerScale(d3, etab.schooling_count, this.maxNbSchoolings, academyBounds)

          const symbolId = getEstablishmentSymbolId(etab)

          d3.select(nodes[i])
            .append("use")
            .attr("href", `#${symbolId}`)
            .attr("width", size)
            .attr("height", size)
            .attr("x", -size/2)
            .attr("y", -size/2)
            .attr("fill", etabMarkerColor(d3, d, this.establishments))
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
    const e = this.establishments[d.properties.Code_UAI]
    const ratio = e.payable_amount > 0 ? e.paid_amount / e.payable_amount : 0

    tooltip
      .style("display", "block")
      .style("left", (event.pageX + 10) + "px")
      .style("top", (event.pageY + 10) + "px")
      .html(`
        <strong>${e.uai} - ${e.name}</strong><br>
        ${e.address_line1}, ${e.city}, ${e.postal_code}<br><br>
        <table>
          <tr><td>Code contrat :</td><td>${e.private_contract_type_code || 'N/A'}</td></tr>
          <tr><td>Nombre de scolarités :</td><td>${e.schooling_count}</td></tr>
          <tr><td>Montant payable :</td><td>${e.payable_amount} €</td></tr>
          <tr><td>Montant payé :</td><td>${e.paid_amount} €</td></tr>
        </table>
        ${createProgressBarHTML(ratio, e.payable_amount, mapColors)}
      `)
  }

  mouseOut(event, d, tooltip) {
    this.d3.select(event.currentTarget).select("use")
      .transition()
      .duration(200)
      .attr("fill", etabMarkerColor(this.d3, d, this.establishments))
    tooltip.style("display", "none")
  }

  setupTableSorting() {
    const table = document.querySelector('.establishments-table')
    const headers = table.querySelectorAll('thead th')
    headers.forEach(header => {
      if (header.textContent.includes('Montant payé')) {
        header.style.cursor = 'pointer'
        const sortArrow = document.createElement('span')
        sortArrow.innerHTML = this.arrowDown
        sortArrow.className = 'sort-arrow'
        sortArrow.style.paddingLeft = '5px'
        header.appendChild(sortArrow)

        header.addEventListener('click', () => {
          this.sortAscending = !this.sortAscending
          this.sortTable(table)
          sortArrow.innerHTML = this.sortAscending ? this.arrowUp : this.arrowDown
        })
      }
    })
  }

  sortTable(table) {
    const tbody = table.querySelector('tbody')
    const rows = Array.from(tbody.querySelectorAll('tr.academic-map'))
    rows.sort((rowA, rowB) => {
      const uaiA = rowA.dataset.uai
      const uaiB = rowB.dataset.uai

      const paidAmountA = this.establishments[uaiA]?.paid_amount || 0
      const paidAmountB = this.establishments[uaiB]?.paid_amount || 0

      return this.sortAscending
        ? paidAmountA - paidAmountB
        : paidAmountB - paidAmountA
    })

    rows.forEach(row => tbody.appendChild(row))
  }
}
