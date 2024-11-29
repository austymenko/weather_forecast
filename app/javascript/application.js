import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import AddressController from "./controllers/address_controller"

const application = Application.start()
application.register("address", AddressController)
