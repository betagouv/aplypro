import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dashboardSections = document.querySelectorAll('.dashboard-section')
    this.timelineSections = document.querySelectorAll('.timeline-section')

    this.activateSection(0)
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }

  handleScroll() {
    const viewportHeight = window.innerHeight

    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight - 20) {
      this.activateSection(this.timelineSections.length - 1)
      return
    }

    this.timelineSections.forEach((section, index) => {
      const sectionTop = section.getBoundingClientRect().top
      const sectionBottom = sectionTop + section.offsetHeight

      if (sectionTop < viewportHeight / 2 && sectionBottom > viewportHeight / 2) {
        this.activateSection(index)
      }
    })
  }

  activateSection(index) {
    this.dashboardSections.forEach(section => section.classList.remove('active'))
    this.dashboardSections[index].classList.add('active')
  }
}
