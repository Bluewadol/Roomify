module StatusBadgeHelper
    def status_badge(status)
        status_classes = {
            "booked" => "bg-red-100 text-red-800",
            "available" => "bg-green-100 text-green-800",
            "unavailable" => "bg-gray-100 text-black",
            "pending" => "bg-yellow-100 text-yellow-800",
            "checked_in" => "bg-blue-100 text-blue-800",
            "canceled" => "bg-red-100 text-red-800",
            "expired" => "bg-gray-100 text-gray-800",
            "completed" => "bg-green-100 text-green-800"
        }

        label = status.to_s.humanize.presence || "Unknown"
        css_class = status_classes[status.to_s] || "bg-gray-500 text-white"

        content_tag :span, label, class: "#{css_class} text-sm px-2 py-1 rounded-2xl h-7"
    end
end
