import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    amounts: { type: String, default: '{}' },
    schoolings: { type: String, default: '{}' }
  }

  async connect() {
    const d3 = await import("d3")
    this.d3 = d3

    try {
      this.parsedAmounts = JSON.parse(this.amountsValue)
      this.parsedSchoolings = JSON.parse(this.schoolingsValue)
      this.initAllMaps()
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

    document.querySelectorAll('.overseas-map').forEach(map => {
      map.removeAttribute('data-initialized')
      map.innerHTML = ''
    })
  }

  initAllMaps() {
    if (!this.parsedAmounts || !this.parsedSchoolings) {
      console.error("Missing data values")
      return
    }

    this.initMap()

    const overseasMaps = [
      { id: 'map-guadeloupe', path: '/data/guadeloupe.geojson', center: [-61.5, 16.25], scale: 10000 },
      { id: 'map-martinique', path: '/data/martinique.geojson', center: [-61.0, 14.6], scale: 10000 },
      { id: 'map-guyane', path: '/data/guyane.geojson', center: [-53.0, 4.0], scale: 1000 },
      { id: 'map-reunion', path: '/data/reunion.geojson', center: [55.5, -21.1], scale: 10000 },
      { id: 'map-mayotte', path: '/data/mayotte.geojson', center: [45.2, -12.8], scale: 15000 },
      { id: 'map-saint-pierre', path: '/data/saint_pierre.geojson', center: [-56.3, 47.0], scale: 10000 }
    ]

    overseasMaps.forEach(map => {
      this.createOverseasMap(map.id, map.path, map.center, map.scale)
    })
  }

  createOverseasMap(containerId, geoJsonPath, centerCoords, scale) {
    const d3 = this.d3
    const container = document.getElementById(containerId)
    if (!container || container.hasAttribute('data-initialized')) return

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    const width = container.offsetWidth
    const height = 140

    const maxAmount = Math.max(...Object.values(this.parsedAmounts))
    const maxSchoolings = Math.max(...Object.values(this.parsedSchoolings))

    const colorScale = d3.scaleLinear()
      .domain([0, maxAmount])
      .range(["#bccdff", "#000091"])

    const strokeScale = d3.scaleLinear()
      .domain([0, maxSchoolings])
      .range([0.5, 2])

    const strokeColorScale = d3.scaleLinear()
      .domain([0, maxSchoolings])
      .range(["#ffbdbd", "#cd0000"])

    const svg = d3.select("#" + containerId)
      .append("svg")
      .attr("width", width)
      .attr("height", height)

    const g = svg.append("g")

    const tooltip = d3.select("#" + containerId)
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
        .attr("fill", d => {
          const amount = this.parsedAmounts[d.properties.CODE_ACAD] || 0
          return colorScale(amount)
        })
        .attr("stroke", d => {
          const schoolingCount = this.parsedSchoolings[d.properties.CODE_ACAD] || 0
          return strokeColorScale(schoolingCount)
        })
        .attr("stroke-width", d => {
          const schoolingCount = this.parsedSchoolings[d.properties.CODE_ACAD] || 0
          return strokeScale(schoolingCount)
        })
        .attr("opacity", 0.7)
        .on("mouseover", (event, d) => this.mouseOver(event, d, tooltip, colorScale))
        .on("mouseout", (event, d) => this.mouseOut(event, d, tooltip, colorScale))
        .on("mousemove", (event, d) => this.mouseMove(event, tooltip))
    }).catch((error) => {
      console.error("Error loading the geo file for " + containerId + ":", error)
    })
  }

  initMap() {
    const d3 = this.d3
    const container = document.getElementById('map-container')
    if (!container || container.hasAttribute('data-initialized')) return

    container.setAttribute('data-initialized', 'true')
    container.innerHTML = ''

    const width = container.offsetWidth
    const height = 540

    const maxAmount = Math.max(...Object.values(this.parsedAmounts))
    const maxSchoolings = Math.max(...Object.values(this.parsedSchoolings))

    const colorScale = d3.scaleLinear()
      .domain([0, maxAmount])
      .range(["#bccdff", "#000091"])

    const strokeScale = d3.scaleLinear()
      .domain([0, maxSchoolings])
      .range([0.5, 2])

    const strokeColorScale = d3.scaleLinear()
      .domain([0, maxSchoolings])
      .range(["#ffbdbd", "#cd0000"])

    const svg = d3.select("#map-container")
      .append("svg")
      .attr("width", width)
      .attr("height", height)

    const g = svg.append("g")

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

    const projection = d3.geoMercator()
      .center([2.454071, 46.279229])
      .scale(2000)
      .translate([width / 2, height / 2])

    const path = d3.geoPath()
      .projection(projection)

    d3.json("/data/metropole.geojson").then((geojson) => {
      g.selectAll("path")
        .data(geojson.features)
        .enter()
        .append("path")
        .attr("d", path)
        .attr("fill", d => {
          const amount = this.parsedAmounts[d.properties.CODE_ACAD] || 0
          return colorScale(amount)
        })
        .attr("stroke", d => {
          const schoolingCount = this.parsedSchoolings[d.properties.CODE_ACAD] || 0
          return strokeColorScale(schoolingCount)
        })
        .attr("stroke-width", d => {
          const schoolingCount = this.parsedSchoolings[d.properties.CODE_ACAD] || 0
          return strokeScale(schoolingCount)
        })
        .attr("opacity", 0.7)
        .on("mouseover", (event, d) => this.mouseOver(event, d, tooltip, colorScale))
        .on("mouseout", (event, d) => this.mouseOut(event, d, tooltip, colorScale))
        .on("mousemove", (event, d) => this.mouseMove(event, tooltip))
    }).catch((error) => {
      console.error("Error loading the geo file:", error)
    })
  }

  mouseOver(event, d, tooltip, colorScale) {
    const amount = this.parsedAmounts[d.properties.CODE_ACAD] || 0
    const schoolingCount = this.parsedSchoolings[d.properties.CODE_ACAD] || 0

    this.d3.select(event.currentTarget)
      .transition()
      .duration(200)
      .attr("fill", "#88fdaa")
      .attr("opacity", 1)

    tooltip
      .style("left", (event.pageX + 10) + "px")
      .style("top", (event.pageY - 10) + "px")
      .style("display", "block")
      .html(`${d.properties.LIBL_ACAD} (${d.properties.CODE_ACAD})<br>${amount.toLocaleString('fr-FR')} €<br>${schoolingCount} scolarités`)
  }

  mouseOut(event, d, tooltip, colorScale) {
    const amount = this.parsedAmounts[d.properties.CODE_ACAD] || 0

    this.d3.select(event.currentTarget)
      .transition()
      .duration(200)
      .attr("fill", colorScale(amount))
      .attr("opacity", 0.7)

    tooltip.style("display", "none")
  }

  mouseMove(event, tooltip) {
    tooltip
      .style("left", (event.pageX + 10) + "px")
      .style("top", (event.pageY - 10) + "px")
  }
}
