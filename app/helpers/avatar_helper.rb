module AvatarHelper
    def avatar_tag(user, size: 40)
        style = "width: #{size}px; height: #{size}px; font-size: #{size / 2}px;"
        image_classes = "rounded-full object-cover border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
        outer_style = "width: #{size}px; height: #{size}px;"
        inner_style = "width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;"
        outer_classes = "rounded-full border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
        inner_classes = "rounded-full bg-primary-500 text-white font-bold text- overflow-hidden"

        if user.avatar.attached?
            if user.avatar.content_type == "image/svg+xml"
                image_tag user.avatar, style: style, class: image_classes
            else
                image_tag user.avatar.variant(resize_to_limit: [size, size]).processed, style: style, class: image_classes
            end
        else
            content_tag :div, class: outer_classes, style: outer_style do
                content_tag :div, user.email[0].upcase, class: inner_classes, style: inner_style
            end
        end
    end
end
