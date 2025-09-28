// app/javascript/controllers/hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello controller connected!")
    alert("Hello Stimulus!")
  }
}