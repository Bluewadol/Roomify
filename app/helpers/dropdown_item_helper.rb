module DropdownItemHelper
    def dropdown_item(icon_name, text, path = "#", method: :get, data_testid: nil, data_action: nil, class: nil)
        active_class = request.path.start_with?(path) ? "text-primary-600 dark:text-primary-400 font-semibold" : "hover:text-primary-600 dark:hover:text-primary-400"
        base_classes = "pl-3 focus:text-primary-600 flex items-center"
        icon_classes = "flex-shrink-0 stroke-current size-5 text-slate-500 group-hover:text-primary-600 dark:group-hover:text-primary-400"
        link_classes = "px-4 py-2 md:py-[.4rem] #{active_class} block #{binding.local_variable_get(:class)}"

        content_tag(:div, role: "none", class: base_classes, data: { testid: data_testid, action: data_action }) do
            concat(icon(icon_name, class: icon_classes))
            concat(
                if method == :delete
                    button_to text, path, method: :delete, class: link_classes
                else
                    link_to text, path, class: link_classes
                end
            )
        end
    end
end
