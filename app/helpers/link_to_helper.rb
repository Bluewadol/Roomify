module LinkToHelper
    def link_to_button(text: "New Reservation", path: root_path, css_class: "bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg")
        link_to path, class: css_class do
            text
        end
    end
end
