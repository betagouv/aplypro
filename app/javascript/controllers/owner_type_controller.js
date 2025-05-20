import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["radioButton", "inputName"]
    static values = {
        studentName: String
    }

    connect() {
        this.updateName()
    }

    updateName() {
        if (this.radioButtonTarget.checked) {
            this.inputNameTarget.value = this.studentNameValue
        }
    }
}
