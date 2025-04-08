import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  async connect() {
    this.d3 = await import("d3")

    try {
      this.selectedAcademy = parseInt(this.element.dataset.selectedAcademyValue)
      this.parsedEstablishments = JSON.parse(this.element.dataset.establishmentsForAcademy)
      this.parsedNbSchoolings = JSON.parse(this.element.dataset.nbSchoolingsPerEstablishments)
      this.parsedAmounts = JSON.parse(this.element.dataset.amountsPerEstablishments)

      this.maxNbSchoolings = Math.max(...Object.values(this.parsedNbSchoolings))
      this.maxAmount = Math.max(...Object.values(this.parsedAmounts))

      this.academies = new Map([
        [1, '/data/academies/01_PARIS.geojson'],
        [2, '/data/academies/02_AIX_MARSEILLE.geojson'],
        [3, '/data/academies/03_BESANCON.geojson'],
        [4, '/data/academies/04_BORDEAUX.geojson'],
        [6, '/data/academies/06_CLERMONT_FERRAND.geojson'],
        [7, '/data/academies/07_DIJON.geojson'],
        [8, '/data/academies/08_GRENOBLE.geojson'],
        [9, '/data/academies/09_LILLE.geojson'],
        [10, '/data/academies/10_LYON.geojson'],
        [11, '/data/academies/11_MONTPELLIER.geojson'],
        [12, '/data/academies/12_NANCY_METZ.geojson'],
        [13, '/data/academies/13_POITIERS.geojson'],
        [14, '/data/academies/14_RENNES.geojson'],
        [15, '/data/academies/15_STRASBOURG.geojson'],
        [16, '/data/academies/16_TOULOUSE.geojson'],
        [17, '/data/academies/17_NANTES.geojson'],
        [18, '/data/academies/18_ORLEANS_TOURS.geojson'],
        [19, '/data/academies/19_REIMS.geojson'],
        [20, '/data/academies/20_AMIENS.geojson'],
        [22, '/data/academies/22_LIMOGES.geojson'],
        [23, '/data/academies/23_NICE.geojson'],
        [24, '/data/academies/24_CRETEIL.geojson'],
        [25, '/data/academies/25_VERSAILLES.geojson'],
        [27, '/data/academies/27_CORSE.geojson'],
        [28, '/data/academies/28_REUNION.geojson'],
        [31, '/data/academies/31_MARTINIQUE.geojson'],
        [32, '/data/academies/32_GUADELOUPE.geojson'],
        [33, '/data/academies/33_GUYANE.geojson'],
        [43, '/data/academies/43_MAYOTTE.geojson'],
        [44, '/data/academies/44_SAINT_PIERRE_ET_MIQUELON.geojson'],
        [70, '/data/academies/70_NORMANDIE.geojson']
      ])

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
    const height = 540

    const svg = d3.select("#" + containerId)
        .append("svg")
        .attr("width", width)
        .attr("height", height)

    const g = svg.append("g");

    const zoom = d3.zoom()
        .scaleExtent([1, 10]) // Zoom entre 1x et 10x
        .on("zoom", (event) => {
          g.attr("transform", event.transform);

          // Mettre à jour la taille des cercles et du contour en fonction du zoom
          g.selectAll("circle")
              .attr("r", d => this.sizeScale(this.parsedNbSchoolings[d.properties.Code_UAI]) / event.transform.k)
              .attr("stroke-width", 1 / event.transform.k); // Épaisseur du contour adaptative
        });

    svg.call(zoom);

    // Charger les couches vectorielles
    Promise.all([
        d3.json(this.academies.get(this.selectedAcademy)),
        d3.json("/data/ETABLISSEMENTS_FRANCE.geojson")
    ]).then(([geojson, pointsGeojson]) => {
      const projection = d3.geoMercator().fitSize([width, height], geojson)

      //Le contour de la carte
      g.selectAll("path")
          .data(geojson.features)
          .join("path")
          .attr("d", d3.geoPath().projection(projection))
          .attr("fill", "none")
          .attr("stroke", "#333");

      const tooltip = d3.select(containerId)
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

      //Les points correspondants aux établissements
      g.selectAll("circle")
          .data(pointsGeojson.features.filter(d => this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)))
          .join("circle")
          .attr("r", d => this.sizeScale(this.parsedNbSchoolings[d.properties.Code_UAI])) // Taille dynamique
          .attr("fill", d => this.colorScale(this.parsedAmounts[d.properties.Code_UAI])) // Couleur dynamique
          .attr("stroke", "#fff")
          .attr("stroke-width", 1.5)
          .attr("cx", d => projection(d.geometry.coordinates)[0])
          .attr("cy", d => projection(d.geometry.coordinates)[1])
          .on("mouseover", (event, d) => this.mouseOver(event, d, tooltip))
          .on("mouseout", (event, d) => this.mouseOut(event, d, tooltip))
    });
  }



  mouseOver(event, d, tooltip) {
    const e = this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI);

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
        .attr("fill", this.colorScale(this.parsedAmounts[d.properties.Code_UAI]))

    tooltip.style("display", "none")
  }



  sizeScale(nbSchoolings) {
    const scale = this.d3.scaleSqrt()
      .domain([0, this.maxNbSchoolings])
      .range([5, 18]); // Taille des cercles (min 3px, max 15px)
    return scale(nbSchoolings || 0);
  }

  colorScale(amount) {
    const scale = this.d3.scaleLinear()
      .domain([0, this.maxAmount])
      .range(["#ffbdbd", "#cd0000"])
    return scale(amount || 0)
  }
}
