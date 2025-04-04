module StatusBadgeHelper
    def status_badge(status)
        status_classes = {
            "booked" => "bg-red-500 text-white",
            "available" => "bg-green-500 text-white",
            "unavailable" => "bg-gray-300 text-black",
            "pending" => "bg-yellow-500 text-white", 
            "checked_in" => "bg-blue-500 text-white", 
            "waiting_check_in" => "bg-orange-500 text-white",
            "canceled" => "bg-red-500 text-white",
            "expired" => "bg-gray-500 text-white",
            "completed" => "bg-green-500 text-white"
        }
        
        content_tag :span, status.capitalize, class: "#{status_classes[status] || 'bg-gray-500 text-white'} text-sm px-2 py-1 rounded-2xl h-7"
    end
end
