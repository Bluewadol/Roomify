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

        const startDate = this.formatDateTime(this.startDateFieldTarget.value);
        const endDate = this.formatDateTime(this.endDateFieldTarget.value);
    
        if (startDate) {
            this.setText("selected-start-date", startDate);
        }
        if (endDate && this.startDateFieldTarget.value !== this.endDateFieldTarget.value) {
            this.setText("dash-date", "-");
            this.setText("selected-end-date", endDate);
        } else {
            this.setText("selected-end-date", ""); 
            this.setText("dash-date", "");
        }
        const startTime = this.formatDateTime(this.startTimeFieldTarget.value);
        const endTime = this.formatDateTime(this.endTimeFieldTarget.value);
    
        if (startTime) {
            this.setText("selected-start-time", startTime);
        }
        if (endTime) {
            this.setText("selected-end-time", endTime);
        }
    
        if (startTime || endTime) {
            this.setText("dash-time", "-");
        } else {
            this.setText("dash-time", "");
        }

        this.updateUrlParams({
            start_date: this.startDateFieldTarget.value,
            end_date: this.endDateFieldTarget.value,
            start_time: this.startTimeFieldTarget.value,
            end_time: this.endTimeFieldTarget.value,
        });
    
        this.setText("selected-description", this.descriptionFieldTarget.value);
    }
    formatDateTime(dateOrTime) {
        if (!dateOrTime) return '';
    
        const date = new Date(dateOrTime);
        
        if (date instanceof Date && !isNaN(date)) {
            return date.toLocaleDateString("en-GB", { day: '2-digit', month: 'short', year: 'numeric' });
        } 
        
        const time = new Date(dateOrTime);

        if (!isNaN(time)) {
            if (time instanceof Date) {
                return time.toLocaleDateString("en-GB", { day: '2-digit', month: 'short', year: 'numeric' });
            }
            const options = { hour: '2-digit', minute: '2-digit', hour12: true };
            const formattedTime = time.toLocaleTimeString('en-US', options);
            return formattedTime;
        }

        return dateOrTime.toString();
    }

    updateUrlParams(params) {
        const url = new URL(window.location);
        Object.keys(params).forEach((key) => {
            if (params[key]) {
                url.searchParams.set(key, params[key]);
            } else {
                url.searchParams.delete(key);
            }
        });
        window.history.pushState({}, '', url);
    }
}
