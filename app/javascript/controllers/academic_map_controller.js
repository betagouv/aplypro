import { Controller } from "@hotwired/stimulus"

import { etabMarkerScale, etabMarkerColor, getAcademyGeoJson } from "../utils/academies"

export default class extends Controller {
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
  }

  createMap() {
    const d3 = this.d3
    const containerId = 'map-container'

    const container = document.getElementById(containerId)
    if (!container || container.hasAttribute('data-initialized')) return

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    const width = container.offsetWidth
    const height = 700

    const svg = d3.select("#" + containerId)
        .append("svg")
        .attr("width", width)
        .attr("height", height)

    const imageLayer = svg.append("g")
    const pathLayer = svg.append("g")

    const projection = d3.geoMercator()
        .scale(1)
        .translate([0, 0])

    const tileLayout = this.d3Tile.tile().size([width, height])

    const path = d3.geoPath().projection(projection)

    const zoom = d3.zoom()
        .scaleExtent([1, Infinity])
        .on("zoom", zoomed)

    d3.json(getAcademyGeoJson(this.selectedAcademy)).then((geojson) => {
          const [[x0, y0], [x1, y1]] = d3.geoPath().projection(projection).bounds(geojson)

          const dx = x1 - x0
          const dy = y1 - y0
          const cx = (x0 + x1) / 2
          const cy = (y0 + y1) / 2

          const scale = 0.95 / Math.max(dx / width, dy / height)
          const translate = [width / 2 - scale * cx, height / 2 - scale * cy]

          projection
              .scale(scale)
              .translate(translate)

          pathLayer.selectAll("path")
              .data(geojson.features)
              .enter()
              .append("path")
              .attr("stroke", "#000")
              .attr("fill", "none")
              .attr("stroke-width", 2)
              .attr("d", path)

          const initialTransform = d3.zoomIdentity
              .translate(translate[0], translate[1])
              .scale(scale * 2 * Math.PI)

          svg.call(zoom)
              .call(zoom.transform, initialTransform)

          zoom.scaleExtent([initialTransform.k * 0.8, Infinity])

        this.createEstablishmentsPoints(pathLayer, projection)
        this.setupTableClickInteraction(projection, svg, zoom)

    }).catch((error) => {
      console.error("Error loading the geo file:", error)
    })

    function zoomed({ transform }) {
      projection
          .scale(transform.k / (2 * Math.PI))
          .translate([transform.x, transform.y])

      const tiles = tileLayout(transform)

      imageLayer.selectAll("image")
          .data(tiles, d => d)
          .join("image")
          .attr("xlink:href", d => `https://a.tile.openstreetmap.org/${d[2]}/${d[0]}/${d[1]}.png`)
          .attr("x", ([x]) => (x + tiles.translate[0]) * tiles.scale)
          .attr("y", ([,y]) => (y + tiles.translate[1]) * tiles.scale)
          .attr("width", tiles.scale)
          .attr("height", tiles.scale)

      pathLayer.selectAll("path")
          .attr("d", path)

      pathLayer.selectAll("circle")
          .attr("cx", d => projection(d.geometry.coordinates)[0])
          .attr("cy", d => projection(d.geometry.coordinates)[1])
    }
  }

  createEstablishmentsPoints(g, projection) {
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

      g.selectAll("circle")
          .data(geojson.features.filter(d => this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)))
          .enter()
          .append("circle")
          .filter(d => d.geometry && d.geometry.coordinates)
          .attr("id", d => `marker-${d.properties.Code_UAI}`)
          .attr("cx", d => projection(d.geometry.coordinates)[0])
          .attr("cy", d => projection(d.geometry.coordinates)[1])
          .attr("r", d => etabMarkerScale(d3, this.parsedNbSchoolings[d.properties.Code_UAI], this.maxNbSchoolings))
          .attr("fill", d => etabMarkerColor(d3, this.parsedAmounts[d.properties.Code_UAI], this.maxAmount))
          .attr("stroke", "black")
          .attr("stroke-width", 1)
          .on("mouseover", (event, d) => this.mouseOver(event, d, tooltip))
          .on("mouseout", (event, d) => this.mouseOut(event, d, tooltip))
          .on("click", (event, d) => {
              document.querySelectorAll("tr.selected").forEach(tr => tr.classList.remove("selected"))
              const row = document.querySelector(`tr.academic-map[data-uai="${d.properties.Code_UAI}"]`)
              if (row) row.classList.add("selected")
          })
    }).catch((error) => {
      console.error("Error loading the geo file:", error)
    })
  }

  setupTableClickInteraction(projection, svg, zoom) {
    document.querySelectorAll("tr.academic-map").forEach(row => {
      row.addEventListener("click", () => {
        const uai = row.dataset.uai
        const marker = document.getElementById(`marker-${uai}`)

        if (marker && marker.__data__?.geometry?.coordinates) {
          const [x, y] = projection(marker.__data__.geometry.coordinates)

          svg.transition()
              .duration(750)
              .call(
                  zoom.transform,
                  this.d3.zoomIdentity
                      .translate(x, y)
                      .scale(2048)
              )

          document.querySelectorAll("tr.selected").forEach(tr => tr.classList.remove("selected"))
          row.classList.add("selected")
        }
      })
    })
  }

  mouseOver(event, d, tooltip) {
    const e = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)

    this.d3.select(event.currentTarget)
        .transition()
        .duration(200)
        .attr("fill", "#88fdaa")

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
