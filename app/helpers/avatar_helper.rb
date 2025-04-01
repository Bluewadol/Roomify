module AvatarHelper
    def avatar_tag(user, size: 40)
        style = "width: #{size}px; height: #{size}px; font-size: #{size / 2}px;"

        if user.avatar.attached?
            if user.avatar.content_type == "image/svg+xml"
                image_tag user.avatar, style: style, class: "rounded-full object-cover border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
            else
                image_tag user.avatar.variant(resize_to_limit: [size, size]).processed, style: style, class: "rounded-full object-cover border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
            end
        else
            content_tag :div, user.email[0].upcase, style: style, class: "flex items-center justify-center rounded-full bg-primary-600 text-white font-bold text-lg"
        end
    end
end
