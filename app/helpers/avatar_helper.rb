module AvatarHelper
    def avatar_tag(user)
        if user.avatar.attached?
            if user.avatar.content_type == "image/svg+xml"
            image_tag user.avatar, class: "rounded-full md:w-10 w-12 md:h-10 h-12 object-cover border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
            else
            image_tag user.avatar.variant(resize_to_limit: [100, 100]).processed, class: "rounded-full md:w-10 w-12 md:h-10 h-12 object-cover border-2 border-transparent group-hover:border-primary-600 transition duration-300 ease-in-out"
            end
        else
            content_tag :div, user.email[0].upcase, class: "flex items-center justify-center rounded-full md:w-10 w-12 md:h-10 h-12 bg-primary-600 text-white font-bold text-lg"
        end
    end
end
