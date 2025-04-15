import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container"]
    static values = {
        count: { type: Number, default: 0 }
    }

    connect() {
        this.countValue = this.containerTarget.querySelectorAll('.amenity-fields').length
    }

    addField() {
        const newAmenity = document.createElement('div')
        newAmenity.className = 'relative amenity-fields'
        newAmenity.innerHTML = `
            <div class="grid grid-cols-1 sm:grid-cols-2 sm:gap-x-10 sm:gap-y-4 gap-4">
                <!-- Amenity Name -->
                <div class="form-group">
                    <label class="form-label">Amenity Name</label>
                    <div class="relative">
                        <input type="text" name="room[room_amenities_attributes][${this.countValue}][amenity_name]" class="form-input" placeholder="Enter amenity name">
                    </div>
                </div>

                <!-- Quantity and Trash Icon in same row -->
                <div class="form-group">
                    <label class="form-label">Quantity</label>
                    <div class="relative flex items-center gap-2">
                        <input type="number" name="room[room_amenities_attributes][${this.countValue}][quantity]" class="form-input" placeholder="Enter quantity">
                        <button type="button"
                                class="text-red-500 hover:text-red-600"
                                data-action="click->room-amenities#removeField">
                        </button>
                    </div>
                </div>
            </div>
        `

        // Clone and append the trash icon from the template
        const trashIconTemplate = document.getElementById('trash-icon-template')
        const trashIcon = trashIconTemplate.content.cloneNode(true)
        newAmenity.querySelector('button').appendChild(trashIcon)

        this.containerTarget.appendChild(newAmenity)
        this.countValue++
    }

    removeField(event) {
        event.target.closest('.amenity-fields').remove()
    }
} 