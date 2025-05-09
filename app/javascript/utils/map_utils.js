function getDsfrColor(cssVar) {
  const value = getComputedStyle(document.documentElement)
    .getPropertyValue(cssVar).trim();
  if (!value) {
    console.error(`Could not get DSFR color for variable ${cssVar}`);
  }
  return value;
}

export const mapColors = {
  darkBlue: getDsfrColor('--blue-france-sun-113-625'),
  normalBlue: getDsfrColor('--blue-france-main-525'),
  lightBlue: getDsfrColor('--blue-france-850-200'),
  lightGreen: getDsfrColor('--success-950-100'),
  normalGreen: getDsfrColor('--success-425-625'),
  darkGreen: getDsfrColor('--success-425-625'),
  lightRed: getDsfrColor('--red-marianne-950-100'),
  normalRed: getDsfrColor('--red-marianne-425-625'),
  darkRed: getDsfrColor('--red-marianne-425-625'),
  normalYellow: getDsfrColor('--yellow-tournesol-850-200'),
  lightYellow: getDsfrColor('--yellow-tournesol-975-75')
}

export function getAcademyGeoJson(academyId) {
  const paddedId = academyId.toString().padStart(2, '0')
  return `/data/academies/${paddedId}.geojson`
}

export function etabMarkerScale(d3, nb, maxNbSchoolings, academyBounds) {
  const [[x0, y0], [x1, y1]] = academyBounds;
  const academyArea = Math.abs((x1 - x0) * (y1 - y0));

  const scale = d3.scaleSqrt()
    .domain([0, maxNbSchoolings])
    .range([10, 30]);

  const areaAdjustment = d3.scaleLog()
    .domain([1, 1000])
    .range([0.5, 1.2])
    .clamp(true);

  return scale(nb || 0) * areaAdjustment(academyArea);
}

export function etabMarkerColor(d3, d, establishments) {
  const establishment = establishments[d.properties.Code_UAI]
  if (!establishment) return 'white'

  if (establishment.payable_amount === 0) return mapColors.normalRed

  const ratio = establishment.paid_amount / establishment.payable_amount
  const colorScale = d3.scaleLinear()
    .domain([0, 0.5, 1])
    .range([mapColors.normalRed, mapColors.normalYellow, mapColors.normalGreen])

  return colorScale(ratio)
}

export function createMapLegend(svg, height, toggleCallback) {
  const legend = svg.append("g")
    .attr("class", "legend")
    .attr("transform", `translate(10, ${height - 40})`)

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
      .on("click", () => toggleCallback(item.type))

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

export function updateLegendAppearance(svg, type, isVisible) {
  svg.select(`#legend-${type}`)
    .selectAll("use, text")
    .style("fill", isVisible ? "black" : "#999")
}

export function toggleBopVisibility(academyLayer, currentVisibleStates, type, establishments) {
  const newStates = { ...currentVisibleStates }
  newStates[type] = !newStates[type]

  const isAgricultureMinistry = type === "masa"

  academyLayer.selectAll("g.marker")
    .filter(d => {
      if (!d.properties || !d.properties.Code_UAI) return false;
      const etab = establishments[d.properties.Code_UAI]
      if (!etab) return false;

      return (etab.ministry === "AGRICULTURE") === isAgricultureMinistry
    })
    .style("display", newStates[type] ? "block" : "none")

  return newStates
}

export function createProgressBarHTML(ratio, payableAmount) {
  if (payableAmount <= 0) return ''

  const percentage = (ratio * 100).toFixed(1)

  return `
    <div class="progress-bar" style="--progress-value: ${percentage}%">
      <div class="indicator"></div>
    </div>
    <div class="progress-percentage">${percentage}%</div>
  `
}
