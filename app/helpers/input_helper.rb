module InputHelper
    def input_class(resource, field, extra_classes: "", has_icon_left: false)
        base_classes = "form-input peer pr-10 #{extra_classes}"
        base_classes += " pl-12" if has_icon_left

        if resource.errors[field].any?
            base_classes += " border-rose-700 text-rose-700 ring-red-50 dark:border-red-400 dark:ring-red-50/10"
        else
            base_classes += " invalid:border-rose-700 invalid:text-red-700 invalid:ring-red-50 dark:invalid:ring-red-50/10"
        end

        base_classes
    end

    def error_icon(resource, field)
        return unless resource.errors[field].any?

        content_tag(:span, class: "absolute right-3 top-3 text-red-700") do
            icon("exclamation-circle", class: "size-5 stroke-current")
        end
    end

    def field_error_tag(resource, field)
        return unless resource.errors[field].any?

        content_tag(:p, resource.errors[field].first, class: "mt-1 text-sm text-rose-700")
    end

    def error_messages(resource)
        render "rui/shared/error_messages", resource: resource if resource.errors.any?
    end
end
