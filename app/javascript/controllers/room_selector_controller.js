import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "roomIdField", "roomBox", "bookingSummary",
        "startDateField", "endDateField", "startTimeField", "endTimeField",
        "startDateFilter", "endDateFilter", "startTimeFilter", "endTimeFilter", "roomIdFilter",
        "descriptionField", "filterForm"
    ];      

    connect() {
        this.isSubmitting = false;
        const roomIdFromParams = new URLSearchParams(window.location.search).get('room_id');

        if (roomIdFromParams) {
            const roomElement = document.querySelector(`[data-room-id="${roomIdFromParams}"]`);

            if (roomElement) {
                this.highlightSelectedRoom(roomElement);
                this.updateBookingSummary();
            }
        }

        // bind input listeners
        if (this.hasStartDateFieldTarget) {
            this.startDateFieldTarget.addEventListener("input", () => {
                this.syncToFilterForm();
                this.updateBookingSummary();
            });
        }
        
        if (this.hasEndDateFieldTarget) {
            this.endDateFieldTarget.addEventListener("input", () => {
                this.syncToFilterForm();
                this.updateBookingSummary();
            });
        }
    
        if (this.hasStartTimeFieldTarget) {
            this.startTimeFieldTarget.addEventListener("input", () => {
                this.syncToFilterForm();
                this.updateBookingSummary();
            });
        }
    
        if (this.hasEndTimeFieldTarget) {
            this.endTimeFieldTarget.addEventListener("input", () => {
                this.syncToFilterForm();
                this.updateBookingSummary();
            });
        }

        const savedDescription = localStorage.getItem("reservation_description");

        if (this.hasDescriptionFieldTarget && !this.descriptionFieldTarget.value && savedDescription) {
            const savedData = JSON.parse(savedDescription);
            const now = new Date().getTime();
        
            if (savedData.expiresAt > now) {
                this.descriptionFieldTarget.value = savedData.value;
                this.updateBookingSummary();
            } else {
                localStorage.removeItem("reservation_description");
            }
        }
        
        if (this.hasDescriptionFieldTarget) {
            this.descriptionFieldTarget.addEventListener("input", () => {
                this.updateBookingSummary();
            
                const value = this.descriptionFieldTarget.value;
                const now = new Date().getTime();
                const expiresAt = now + 30 * 60 * 1000;
            
                const data = {
                    value: value,
                    expiresAt: expiresAt
                };
            
                localStorage.setItem("reservation_description", JSON.stringify(data));
            });
        }        

        this.updateBookingSummary();
    }

    select(event) {
        const roomId = event.currentTarget.getAttribute("data-room-id");
        this.roomIdFieldTarget.value = roomId;
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
        const roomName = selectedRoom?.dataset.roomName || "Please select room";
    
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

    syncFilterFormValuesOnly() {
        if (this.hasStartDateFieldTarget && this.hasStartDateFilterTarget) {
            this.startDateFilterTarget.value = this.startDateFieldTarget.value;
        }
        if (this.hasEndDateFieldTarget && this.hasEndDateFilterTarget) {
            this.endDateFilterTarget.value = this.endDateFieldTarget.value;
        }
        if (this.hasStartTimeFieldTarget && this.hasStartTimeFilterTarget) {
            this.startTimeFilterTarget.value = this.startTimeFieldTarget.value;
        }
        if (this.hasEndTimeFieldTarget && this.hasEndTimeFilterTarget) {
            this.endTimeFilterTarget.value = this.endTimeFieldTarget.value;
        }
        if (this.hasRoomIdFieldTarget && this.hasRoomIdFilterTarget) {
            this.roomIdFilterTarget.value = this.roomIdFieldTarget.value;
        }
    }
    
    submitFilterForm() {
        if (this.hasFilterFormTarget) {
            this.filterFormTarget.requestSubmit();
        }
    }
    
    syncToFilterForm() {
        if (this.isSubmitting) return; 

        this.isSubmitting = true; 
        this.syncFilterFormValuesOnly();
        this.submitFilterForm();
        clearTimeout(this.submitTimeout);
        setTimeout(() => {
            this.isSubmitting = false;
        }, 300);
    }    
}
