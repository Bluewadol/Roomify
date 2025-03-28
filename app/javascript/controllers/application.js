import { Application } from "@hotwired/stimulus"
import FlashController from "./flash_controller"
import ImageUploadController from "./image_upload_controller"
import FilterFormController from "./filter_form_controller"

const application = Application.start()
application.debug = false
window.Stimulus = application

// Manually register the flash controller
application.register("flash", FlashController)
application.register("image_upload", ImageUploadController)
application.register("filter_form", FilterFormController)

export { application }
