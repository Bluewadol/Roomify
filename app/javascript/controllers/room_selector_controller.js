import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "roomIdField", "roomBox", "bookingSummary",
        "startDateField", "endDateField",
        "startTimeField", "endTimeField",
        "descriptionField"
    ];

    connect() {
        const roomIdFromParams = new URLSearchParams(window.location.search).get('room_id');

        if (roomIdFromParams) {
            const roomElement = document.querySelector(`[data-room-id="${roomIdFromParams}"]`);

            if (roomElement) {
                this.highlightSelectedRoom(roomElement);
                this.updateBookingSummary();
            }
        }

        // bind input listeners
        this.startDateFieldTarget.addEventListener("input", () => this.updateBookingSummary());
        this.endDateFieldTarget.addEventListener("input", () => this.updateBookingSummary());
        this.startTimeFieldTarget.addEventListener("input", () => this.updateBookingSummary());
        this.endTimeFieldTarget.addEventListener("input", () => this.updateBookingSummary());
        this.descriptionFieldTarget.addEventListener("input", () => this.updateBookingSummary());
    }

    select(event) {
        const roomId = event.currentTarget.getAttribute("data-room-id");
        this.roomIdFieldTarget.value = roomId;
        const currentPath = window.location.pathname;
        const newUrl = new URL(window.location);
        newUrl.searchParams.set('room_id', roomId);

        window.history.pushState({}, '', newUrl);
        this.highlightSelectedRoom(event.currentTarget);
        this.updateBookingSummary();
    }

    highlightSelectedRoom(selectedRoom) {
        this.roomBoxTargets.forEach((room) => {
            room.classList.remove("bg-blue-200");
        });
        selectedRoom.classList.add("bg-blue-200");
    }

    setText(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }
    
    updateBookingSummary() {
        const selectedRoom = this.roomBoxTargets.find(room => room.classList.contains("bg-blue-200"));
        const roomName = selectedRoom?.dataset.roomName || "No Room Selected";

        this.setText("selected-room-name", roomName);
        this.setText("selected-start-date", this.startDateFieldTarget.value);
        if (this.endDateFieldTarget.value && this.startDateFieldTarget.value !== this.endDateFieldTarget.value) {
            this.setText("dash-date", "-");
            this.setText("selected-end-date", this.endDateFieldTarget.value);
        } else {
            this.setText("selected-end-date", ""); 
            this.setText("dash-date", "");
        }
        this.setText("selected-start-time", this.startTimeFieldTarget.value);
        if (this.startTimeFieldTarget.value || this.endTimeFieldTarget.value) {
            this.setText("dash-time", "-");
        } else {
            this.setText("dash-time", "");
        }
        this.setText("selected-end-time", this.endTimeFieldTarget.value);
        this.setText("selected-description", this.descriptionFieldTarget.value);
    } 
}
