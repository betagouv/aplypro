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
  normalYellow: getDsfrColor('--yellow-tournesol-850-200')
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

export function etabMarkerColor(d3, d, amounts) {
  const establishment = amounts[d.properties.Code_UAI]
  if (!establishment) return 'white'

  if (establishment.payable_amount === 0) return mapColors.normalRed

  const ratio = establishment.paid_amount / establishment.payable_amount
  const colorScale = d3.scaleLinear()
    .domain([0, 0.5, 1])
    .range([mapColors.normalRed, mapColors.normalYellow, mapColors.normalGreen])

  return colorScale(ratio)
}
