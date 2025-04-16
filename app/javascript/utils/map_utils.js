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

export const ACADEMIES = {
  1: 'PARIS',
  2: 'AIX_MARSEILLE',
  3: 'BESANCON',
  4: 'BORDEAUX',
  6: 'CLERMONT_FERRAND',
  7: 'DIJON',
  8: 'GRENOBLE',
  9: 'LILLE',
  10: 'LYON',
  11: 'MONTPELLIER',
  12: 'NANCY_METZ',
  13: 'POITIERS',
  14: 'RENNES',
  15: 'STRASBOURG',
  16: 'TOULOUSE',
  17: 'NANTES',
  18: 'ORLEANS_TOURS',
  19: 'REIMS',
  20: 'AMIENS',
  22: 'LIMOGES',
  23: 'NICE',
  24: 'CRETEIL',
  25: 'VERSAILLES',
  27: 'CORSE',
  28: 'REUNION',
  31: 'MARTINIQUE',
  32: 'GUADELOUPE',
  33: 'GUYANE',
  43: 'MAYOTTE',
  44: 'SAINT_PIERRE_ET_MIQUELON',
  70: 'NORMANDIE'
}

export function getAcademyGeoJson(academyId) {
  const academyName = ACADEMIES[academyId]
  const paddedId = academyId.toString().padStart(2, '0')
  return academyName ? `/data/academies/${paddedId}_${academyName}.geojson` : null
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
