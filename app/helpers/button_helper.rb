module ButtonHelper
    def btn_link_to(text, path, btn_class: "btn-white", icon_name: nil, variant: :solid, **options, &block)
        options[:class] = "btn #{btn_class} flex items-center space-x-2 min-h-10 #{options[:class]}"

        link_to path, options do
            concat(icon(icon_name, class: "size-5", variant: variant)) if icon_name
            concat(content_tag(:span, text))
        end
    end
end
