module AvatarHelper
    def avatar_tag(user, size: 40, preview: false, form: nil, modal: false)
        return content_tag(:div, "?", class: "rounded-full bg-gray-300 text-white font-bold flex items-center justify-center", style: "width: #{size}px; height: #{size}px; font-size: #{size / 2}px;") unless user

        style = "width: #{size}px; height: #{size}px; font-size: #{size / 2}px;"
        image_classes = "rounded-full object-cover border-2 border-neutral-200 dark:border-neutral-700 group-hover:border-primary-600 transition duration-300 ease-in-out"
        image_preview_classes = "rounded-full object-cover border-4 border-neutral-200 dark:border-neutral-700 group-hover:border-primary-600 transition duration-300 ease-in-out text-xl bg-primary-500 dark:bg-primary-600 text-white min-w-[100px] min-h-[100px] flex items-center justify-center"
        outer_style = "width: #{size}px; height: #{size}px; font-size: #{size / 2}px;"
        inner_style = "width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; font-size: #{size / 2}px;"
        outer_classes = "rounded-full border-1 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out bg-primary-500 dark:bg-primary-600 text-white"
        inner_classes = "rounded-full bg-primary-500 text-white font-bold overflow-hidden flex items-center justify-center"

        initial = user.name&.first&.upcase || user.email&.first&.upcase || "?"

        if preview && form
            content_tag :div, class: "relative flex items-center justify-start gap-4 w-full" do
                concat content_tag(:div, initial, class: image_preview_classes, style: outer_style, id: "avatar-preview")

                concat form.file_field(:avatar,
                    class: "form-file w-auto",
                    id: "avatar-input",
                    accept: "image/*",
                    data: {
                        controller: "avatar-preview",
                        action: "change->avatar-preview#preview"
                    }
                )
                concat content_tag(:label,
                content_tag(:div, class: "absolute bottom-0 left-0 w-[100px] h-[100px] flex items-center justify-center bg-black/50 opacity-0 hover:opacity-100 transition-opacity rounded-full cursor-pointer") do
                    content_tag(:span, "✎", class: "text-white text-sm")
                end,
                for: "avatar-input",
                class: "absolute bottom-0 left-0 cursor-pointer"
                )
            end
        elsif user.persisted? && user.avatar.attached?
            begin
                image_options = {
                    style: style,
                    class: image_classes
                }

                if modal
                    image_options[:class] += " cursor-pointer"
                    image_options[:data] = {
                        action: "click->railsui-modal#open",
                        "railsui-modal-target": "button"
                    }
                end

                if user.avatar.content_type == "image/svg+xml"
                    image_tag user.avatar, **image_options
                elsif user.avatar.variable?
                    image_tag user.avatar.variant(resize_to_limit: [ size, size ]).processed, **image_options
                else
                    image_tag user.avatar, **image_options
                end
            rescue StandardError => e
                content_tag :div, class: outer_classes, style: outer_style do
                    content_tag :div, initial, class: image_classes, style: inner_style
                end
            end
        else
            outer_classes_with_modal = outer_classes.dup
            outer_classes_with_modal += " cursor-pointer" if modal

            content_tag :div, class: outer_classes_with_modal, style: outer_style,
            data: (modal ? { action: "click->railsui-modal#open", "railsui-modal-target": "button" } : {}) do
                content_tag :div, initial, class: image_classes, style: inner_style
            end
        end
    end

    def avatar_preview(user, size: 100)
        content_tag :div, class: "flex items-center space-x-4 mb-6" do
        concat avatar_tag(user, size: size)
            concat content_tag(:div, class: "flex-1") do
                concat content_tag(:h2, user.name, class: "text-xl font-semibold")
                concat content_tag(:p, user.email, class: "text-gray-600")
            end
        end
    end
end
