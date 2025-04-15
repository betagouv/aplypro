export const ACADEMIES = {
  1: '01_PARIS',
  2: '02_AIX_MARSEILLE',
  3: '03_BESANCON',
  4: '04_BORDEAUX',
  6: '06_CLERMONT_FERRAND',
  7: '07_DIJON',
  8: '08_GRENOBLE',
  9: '09_LILLE',
  10: '10_LYON',
  11: '11_MONTPELLIER',
  12: '12_NANCY_METZ',
  13: '13_POITIERS',
  14: '14_RENNES',
  15: '15_STRASBOURG',
  16: '16_TOULOUSE',
  17: '17_NANTES',
  18: '18_ORLEANS_TOURS',
  19: '19_REIMS',
  20: '20_AMIENS',
  22: '22_LIMOGES',
  23: '23_NICE',
  24: '24_CRETEIL',
  25: '25_VERSAILLES',
  27: '27_CORSE',
  28: '28_REUNION',
  31: '31_MARTINIQUE',
  32: '32_GUADELOUPE',
  33: '33_GUYANE',
  43: '43_MAYOTTE',
  44: '44_SAINT_PIERRE_ET_MIQUELON',
  70: '70_NORMANDIE'
}

export function getAcademyGeoJson(academyId) {
  const academyName = ACADEMIES[academyId]
  return academyName ? `/data/academies/${academyName}.geojson` : null
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
    .range(["#fcbfbf", "#e1000f"])
  return scale(amount || 0)
}
