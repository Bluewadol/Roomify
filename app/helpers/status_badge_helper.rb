module StatusBadgeHelper
    def status_badge(status)
        status_classes = {
            "booked" => "bg-red-500 text-white",
            "available" => "bg-green-500 text-white",
            "unavailable" => "bg-gray-300 text-black"
        }
        
        content_tag :span, status.capitalize, class: "#{status_classes[status] || 'bg-gray-500 text-white'} px-2 py-1 rounded-2xl h-8"
    end
end
