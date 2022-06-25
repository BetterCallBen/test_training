import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "apartments", "secondRoomsInput", "secondSurfaceInput", "locations", "locationResults", "types"]
  static values = { locationInsees: Array, apartmentTypes: Array }

  connect() {
    this.locationInsees = this.locationInseesValue
    console.log(this.locationInsees)
    this.apartmentTypes = this.apartmentTypesValue
    console.log(this.apartmentTypes)
  }

  toggleType(event) {
    const type = event.currentTarget.value

    if (this.apartmentTypes.includes(type)) {
      const index = this.apartmentTypes.indexOf(type)
      if (index > -1) {
        this.apartmentTypes.splice(index, 1)
      }
    } else {
      this.apartmentTypes.push(type)
    }
    this.typesTarget.value = this.apartmentTypes

    this.submitForm()
  }


  searchLocations(event) {
    const baseUrl = document.location.href
    if (baseUrl.includes("?")) {
      this.url = `${baseUrl}&search=${event.currentTarget.value}`
    } else {
      this.url = `${baseUrl}?search=${event.currentTarget.value}`
    }
    fetch(this.url,
      { method: "GET",
        headers: { "Accept": "text/plain" }
      })
      .then(response => response.text())
      .then(text => this.locationResultsTarget.innerHTML = text)
  }

  addLocation(event) {
    this.locationInsees.push(event.currentTarget.dataset.inseeCode)
    this.locationsTarget.value = this.locationInsees

    this.submitForm()
  }

  removeLocation(event) {
    const inseeCode = event.currentTarget.dataset.inseeCode
    const index = this.locationInsees.indexOf(inseeCode)
    if (index > -1) {
      this.locationInsees.splice(index, 1)
    }
    this.locationsTarget.value = this.locationInsees
    this.submitForm()
  }

  submitForm() {
    this.formTarget.submit()
  }

  changeRooms(event) {
    if (event.currentTarget.value !== "" || event.keyCode === 13) {
      if (this.secondRoomsInputTarget.value !== "") {
        this.formTarget.submit()
      } else {
        this.secondRoomsInputTarget.select()
      }
    }
  }

  validRooms(event) {
    if (event.currentTarget.value !== "" || event.keyCode === 13) {
      this.formTarget.submit()
    }
  }

  changeSurface(event) {
    if (event.keyCode === 13 || event.currentTarget.value.length === 3) {
      if (this.secondSurfaceInputTarget.value !== "") {
        this.formTarget.submit()
      } else {
        this.secondSurfaceInputTarget.select()
      }
    }
  }

  validSurface(event) {
    if (event.keyCode === 13 || event.currentTarget.value.length === 3) {
      this.formTarget.submit()
    }
  }
}
