module IconsHelper
  VALID_SVG_ATTRIBUTES = %i[
    width height viewBox fill stroke stroke-width stroke-linecap stroke-linejoin class xmlns
  ].freeze
  def render_icon(name, **options)
    filtered_options = options.slice(*VALID_SVG_ATTRIBUTES)
    render "/shared/icons/#{name}", **filtered_options
  end
  def render_icon_file(filename, **options)
    filtered_options = options.slice(*VALID_SVG_ATTRIBUTES)
    svg_content = Rails.root.join("app/assets/images/#{filename}.svg").read
    svg_content.sub!("<svg", "<svg #{tag.attributes(filtered_options)} ")
    raw(svg_content)
  end
end
