import {Controller} from "@hotwired/stimulus"
import L from "leaflet"

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

      this.createMap()
    } catch (error) {
      console.error("Error parsing data:", error)
    }
  }

  disconnect() {
    this.map.remove()
  }

  createMap() {
    this.map = L.map('map-container', {attributionControl: false})

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map);

    this.addAcademyLayer()
    this.addEstablishmentsLayer()
  }

  addAcademyLayer(){
    const geoJsonPath = this.getAcademyPath()

    fetch(geoJsonPath)
        .then(response => response.json())
        .then(geoJson => {
          const geoJsonLayer = L.geoJSON(geoJson, {
            style: {
              color: "#333",
              fillColor: "#afe8c0",
              fillOpacity: 0.2,
              weight: 2,
              interactive: false
            }
          }).addTo(this.map)

          // Adapter le zoom et le centrage sur le GeoJSON
          this.map.fitBounds(geoJsonLayer.getBounds());
        }).catch((error) => {
          console.error("Error loading the academic geo file:", error)
        })
  }

  addEstablishmentsLayer() {
    const geoJsonPath = "/data/ETABLISSEMENTS_FRANCE.geojson"

    fetch(geoJsonPath)
        .then(response => response.json())
        .then(geoJson => {
          // Filtrer les points en fonction des établissements de l'académie
          const filteredFeatures = geoJson.features.filter(d =>
              this.parsedEstablishments.find(e => e.uai === d.properties.Code_UAI)
          );

          const markers = {}

          L.geoJSON({ type: "FeatureCollection", features: filteredFeatures }, {
            pointToLayer: (feature, layer) => {
              const marker = this.createPointMarker(feature, layer)
              markers[feature.properties.Code_UAI] = marker
              return marker
            },
            onEachFeature: (feature, layer) => this.handleFeatureInteractions(feature, layer)
          }).addTo(this.map);

          this.setupTableClickInteraction(markers)
        }).catch((error) => {
          console.error("Error loading the establishment geo file:", error)
        })
  }



  handleFeatureInteractions(feature, layer) {
    const map = this.map
    const e = this.parsedEstablishments.find(e => e.uai === feature.properties.Code_UAI);

    layer.bindPopup(`
       ${e.uai} - ${e.name}<br>
       ${e.address_line1}, ${e.city}, ${e.postal_code}<br>
       Nombre de scolarités : ${this.parsedNbSchoolings[e.uai]}<br>
       Montant total payé : ${this.parsedAmounts[e.uai]} €
    `);

    layer.on("click", function() {
      map.flyTo(layer.getLatLng(), Math.max(map.getZoom(), 10), {
        duration: 1,
        easeLinearity: 0.25
      });

      document.querySelectorAll("tr.academic-map.selected").forEach(row => row.classList.remove("selected"));

      const row = document.querySelector(`tr[data-uai="${e.uai}"]`)
      if(row) {
        row.classList.add("selected")
        row.scrollIntoView({ behavior: "smooth", block: "center" })
      }
    })
  }

  setupTableClickInteraction(markers) {
    const map = this.map
    document.querySelectorAll("tr.academic-map").forEach(row => {
      row.addEventListener("click", function() {
        const marker = markers[this.dataset.uai]

        if(marker) {
          marker.openPopup()

          map.flyTo(marker.getLatLng(), Math.max(map.getZoom(), 10), {
            duration: 1,
            easeLinearity: 0.25
          })
        }

        document.querySelectorAll("tr.selected").forEach(tr => tr.classList.remove("selected"))
        this.classList.add("selected")
      })
    })
  }

  createPointMarker(feature, layer) {
    return L.circleMarker(layer, {
      radius: this.sizeScale(this.parsedNbSchoolings[feature.properties.Code_UAI]), // Taille dynamique
      fillColor: this.colorScale(this.parsedAmounts[feature.properties.Code_UAI]), // Couleur dynamique
      color: "black",
      weight: 1,
      fillOpacity: 0.8
    });
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



  getAcademyPath() {
    if (!this.selectedAcademy) {
      console.error("Missing data values")
      return
    }

    const academies = [
      { id: 'academy-1', path: '/data/academies/01_PARIS.geojson' },
      { id: 'academy-2', path: '/data/academies/02_AIX_MARSEILLE.geojson' },
      { id: 'academy-3', path: '/data/academies/03_BESANCON.geojson' },
      { id: 'academy-4', path: '/data/academies/04_BORDEAUX.geojson' },
      { id: 'academy-6', path: '/data/academies/06_CLERMONT_FERRAND.geojson' },
      { id: 'academy-7', path: '/data/academies/07_DIJON.geojson' },
      { id: 'academy-8', path: '/data/academies/08_GRENOBLE.geojson' },
      { id: 'academy-9', path: '/data/academies/09_LILLE.geojson' },
      { id: 'academy-10', path: '/data/academies/10_LYON.geojson' },
      { id: 'academy-11', path: '/data/academies/11_MONTPELLIER.geojson' },
      { id: 'academy-12', path: '/data/academies/12_NANCY_METZ.geojson' },
      { id: 'academy-13', path: '/data/academies/13_POITIERS.geojson' },
      { id: 'academy-14', path: '/data/academies/14_RENNES.geojson' },
      { id: 'academy-15', path: '/data/academies/15_STRASBOURG.geojson' },
      { id: 'academy-16', path: '/data/academies/16_TOULOUSE.geojson' },
      { id: 'academy-17', path: '/data/academies/17_NANTES.geojson' },
      { id: 'academy-18', path: '/data/academies/18_ORLEANS_TOURS.geojson' },
      { id: 'academy-19', path: '/data/academies/19_REIMS.geojson' },
      { id: 'academy-20', path: '/data/academies/20_AMIENS.geojson' },
      { id: 'academy-22', path: '/data/academies/22_LIMOGES.geojson' },
      { id: 'academy-23', path: '/data/academies/23_NICE.geojson' },
      { id: 'academy-24', path: '/data/academies/24_CRETEIL.geojson' },
      { id: 'academy-25', path: '/data/academies/25_VERSAILLES.geojson' },
      { id: 'academy-27', path: '/data/academies/27_CORSE.geojson' },
      { id: 'academy-28', path: '/data/academies/28_REUNION.geojson' },
      { id: 'academy-31', path: '/data/academies/31_MARTINIQUE.geojson' },
      { id: 'academy-32', path: '/data/academies/32_GUADELOUPE.geojson' },
      { id: 'academy-33', path: '/data/academies/33_GUYANE.geojson' },
      { id: 'academy-43', path: '/data/academies/43_MAYOTTE.geojson' },
      { id: 'academy-44', path: '/data/academies/44_SAINT_PIERRE_ET_MIQUELON.geojson' },
      { id: 'academy-70', path: '/data/academies/70_NORMANDIE.geojson' }
    ]

    let value;
    academies.forEach(academy => {
      if(academy.id === 'academy-' + this.selectedAcademy){
        value = academy.path;
      }
    })
    return value;
  }
}
