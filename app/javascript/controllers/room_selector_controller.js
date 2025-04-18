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
        
        const urlParams = new URLSearchParams(window.location.search);
        const now = new Date();
        const bangkokDate = new Date(now.toLocaleString("en-US", { timeZone: "Asia/Bangkok" }));
        const yyyy = bangkokDate.getFullYear();
        const mm = String(bangkokDate.getMonth() + 1).padStart(2, '0'); 
        const dd = String(bangkokDate.getDate()).padStart(2, '0');
        const formattedDate = `${yyyy}-${mm}-${dd}`;
        const hours = bangkokDate.getHours().toString().padStart(2, '0');
        const minutes = bangkokDate.getMinutes().toString().padStart(2, '0');
        const formattedTime = `${hours}:${minutes}`;

        // Set values from URL parameters if they exist
        if (this.hasStartDateFieldTarget) {
            this.startDateFieldTarget.value = urlParams.get("start_date") || formattedDate;
            if (this.hasStartDateFilterTarget) {
                this.startDateFilterTarget.value = urlParams.get("start_date") || formattedDate;
            }
        }

        if (this.hasEndDateFieldTarget) {
            this.endDateFieldTarget.value = urlParams.get("end_date") || formattedDate;
            if (this.hasEndDateFilterTarget) {
                this.endDateFilterTarget.value = urlParams.get("end_date") || formattedDate;
            }
        }

        if (this.hasStartTimeFieldTarget) {
            this.startTimeFieldTarget.value = urlParams.get("start_time") || formattedTime;
            if (this.hasStartTimeFilterTarget) {
                this.startTimeFilterTarget.value = urlParams.get("start_time") || formattedTime;
            }
        }

        if (this.hasEndTimeFieldTarget) {
            this.endTimeFieldTarget.value = urlParams.get("end_time") || formattedTime;
            if (this.hasEndTimeFilterTarget) {
                this.endTimeFilterTarget.value = urlParams.get("end_time") || formattedTime;
            }
        }

        // Ensure URL parameters are set
        if (!urlParams.has("start_date")) urlParams.set("start_date", formattedDate);
        if (!urlParams.has("end_date")) urlParams.set("end_date", formattedDate);
        if (!urlParams.has("start_time")) urlParams.set("start_time", formattedTime);
        if (!urlParams.has("end_time")) urlParams.set("end_time", formattedTime);

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

        // Check if we're on a new or edit reservation page
        const isReservationForm = window.location.pathname.match(/\/reservations\/(new|\d+\/edit)/);
        const savedDescription = localStorage.getItem("reservation_description");

        if (this.hasDescriptionFieldTarget && !this.descriptionFieldTarget.value && savedDescription && isReservationForm) {
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

        const newUrl = new URL(window.location);
        newUrl.search = urlParams.toString();
        window.history.pushState({}, "", newUrl);
    }

    updateValue() {
        const isReservationForm = window.location.pathname.match(/\/reservations\/(new|\d+\/edit)/);
        const isReservationList = window.location.pathname === '/reservations';
        
        if (!isReservationForm && !isReservationList) {
            localStorage.removeItem("reservation_description");
        }
    }

    disconnect() {
        const isReservationForm = window.location.pathname.match(/\/reservations\/(new|\d+\/edit)/);
        const isReservationList = window.location.pathname === '/reservations';
        
        if (!isReservationForm && !isReservationList) {
            localStorage.removeItem("reservation_description");
        }
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

        const startDate = this.formatDate(this.startDateFieldTarget.value);
        const endDate = this.formatDate(this.endDateFieldTarget.value);
    
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
        
        const startTime = this.formatTime(this.startTimeFieldTarget.value);
        console.log("startTime", startTime);
        const endTime = this.formatTime(this.endTimeFieldTarget.value);
        console.log("endTime", endTime);
        console.log("startTime in updateBookingSummary", this.startTimeFieldTarget.value);
        console.log("endTime in updateBookingSummary", this.endTimeFieldTarget.value);
    
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

    formatDate(value) {
        if (!value) return '';
    
        const date = new Date(value);
        if (isNaN(date)) return value.toString();
    
        return date.toLocaleDateString("en-GB", {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            timeZone: 'Asia/Bangkok'
        });
    }

    formatTime(value) {
        if (!value) return '';
    
        const timeMatch = value.match(/^(\d{2}):(\d{2})$/);
        
        if (timeMatch) {
            const [hour, minutes] = [parseInt(timeMatch[1]), timeMatch[2]];
            
            if (hour > 23 || minutes > 59) {
                return 'Invalid time';
            }
    
            const date = new Date();
            date.setHours(hour);
            date.setMinutes(minutes);
            return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', hour12: false });
        }
    
        return value.toString(); 
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
            console.log("submitFilterForm");
            this.filterFormTarget.submit();
        }
    }
    
    syncToFilterForm() {
        console.log("syncToFilterForm");
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
