function getDsfrColor(cssVar) {
  const value = getComputedStyle(document.documentElement)
    .getPropertyValue(cssVar).trim();
  if (!value) {
    console.error(`Could not get DSFR color for variable ${cssVar}`);
  }
  return value;
}

export const mapColors = {
  lightBlue: getDsfrColor('--blue-france-sun-113-625'),
  normalBlue: getDsfrColor('--blue-france-main-525'),
  darkBlue: getDsfrColor('--blue-france-850-200'),

  lightGreen: getDsfrColor('--success-950-100'),
  normalGreen: getDsfrColor('--success-425-625'),
  darkGreen: getDsfrColor('--success-425-625'),

  lightRed: getDsfrColor('--red-marianne-950-100'),
  normalRed: getDsfrColor('--red-marianne-425-625'),
  darkRed: getDsfrColor('--red-marianne-425-625')
}

export function getAcademyGeoJson(academyId) {
  const paddedId = academyId.toString().padStart(2, '0')
  return `/data/academies/${paddedId}.geojson`
}

export function etabMarkerScale(d3, nb, maxNbSchoolings) {
  const scale = d3.scaleSqrt()
    .domain([0, maxNbSchoolings])
    .range([5, 18])
  return scale(nb || 0)
}

export function etabMarkerColor(d3, amount, maxAmount) {
  const scale = d3.scaleLinear()
    .domain([0, maxAmount])
    .range([mapColors.lightRed, mapColors.darkRed])
  return scale(amount || 0)
}
