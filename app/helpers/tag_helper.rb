module TagHelper
    def badge_tag(text, color_class = "")
        classes = ["px-2 py-1 rounded-full text-sm", color_class.presence].compact.join(" ")
        content_tag(:span, text, class: classes)
    end
end
