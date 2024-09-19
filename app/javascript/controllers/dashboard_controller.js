import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timelineContainer = document.getElementById('timeline-container')
    this.dashboardSections = document.querySelectorAll('.dashboard-section')
    this.timelineSections = document.querySelectorAll('.timeline-section')

    this.activateSection(0)
    this.timelineContainer.addEventListener('scroll', this.handleScroll.bind(this))
  }

  handleScroll() {
    const containerHeight = this.timelineContainer.clientHeight
    const scrollPosition = this.timelineContainer.scrollTop
    const scrollHeight = this.timelineContainer.scrollHeight

    if (scrollPosition + containerHeight >= scrollHeight - 20) {
      this.activateSection(this.timelineSections.length - 1)
      return
    }

    this.timelineSections.forEach((section, index) => {
      const sectionTop = section.offsetTop - scrollPosition
      const sectionBottom = sectionTop + section.offsetHeight

      if (sectionTop < containerHeight / 2 && sectionBottom > containerHeight / 2) {
        this.activateSection(index)
      }
    })
  }

  activateSection(index) {
    this.dashboardSections.forEach(section => section.classList.remove('active'))
    this.dashboardSections[index].classList.add('active')
  }
}
