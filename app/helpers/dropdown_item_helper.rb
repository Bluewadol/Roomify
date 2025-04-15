module DropdownItemHelper
    def dropdown_item(icon_name, text, path = "#", method: :get, data_testid: nil, data_action: nil)
        active_class = request.path.start_with?(path) ? "text-primary-600 dark:text-primary-400 font-semibold" : "hover:text-primary-600 dark:hover:text-primary-400"
        
        content_tag(:div, role: "none", class: "pl-3 focus:text-primary-600 flex items-center", data: { testid: data_testid, action: data_action }) do
        concat(icon(icon_name, class: "flex-shrink-0 stroke-current size-5 text-slate-500 group-hover:text-primary-600 dark:group-hover:text-primary-400"))
        concat(
            if method == :delete
                button_to text, path, method: :delete, class: "px-4 py-2 md:py-[.4rem] #{active_class} block"
            else
                link_to text, path, class: "px-4 py-2 md:py-[.4rem] #{active_class} block"
            end
        )
        end
    end
end
