import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["personalButton", "studentNameInput"]
    static values = {
        studentName: String
    }

    connect() {
        this.updateName()
    }

    updateName() {
        if (this.personalButtonTarget.checked) {
            this.studentNameInputTarget.value = this.studentNameValue
        }
    }
}
