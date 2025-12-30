import { Application } from "@hotwired/stimulus"
import TimerController from "./timer_controller"

const application = Application.start()

application.debug = false
window.Stimulus = application

export { application }