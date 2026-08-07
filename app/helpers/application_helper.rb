module ApplicationHelper
  # Every link that appears in the masthead row, the docked bar, the
  # full-screen menu and the footer. One list, four renderings.
  NAV_ITEMS = [
    { label: "Resume",  path: "/resume"  },
    { label: "Meet",    path: "/meet"    },
    { label: "SC26",    path: "/sc26"    },
    { label: "SC24",    path: "/sc24"    },
    { label: "SC23",    path: "/sc23"    },
    { label: "Courses", path: "/courses" }
  ].freeze

  SOCIAL_ITEMS = [
    { label: "LinkedIn",      icon: "linkedin",      url: "https://www.linkedin.com/in/ryanscherbarth/" },
    { label: "GitHub",        icon: "github",        url: "https://github.com/rysc3" },
    { label: "Instagram",     icon: "instagram",     url: "https://www.instagram.com/ry.sc3/" },
    { label: "Email",         icon: "mail",          url: "mailto:online@ryanscherbarth.com" }
  ].freeze

  def nav_items
    NAV_ITEMS
  end

  def social_items
    SOCIAL_ITEMS
  end

  # Pull a glyph out of the inline sprite rendered once per page.
  def icon(name, css: nil, size: nil)
    style = size ? "width:#{size};height:#{size}" : nil
    content_tag :svg, class: ["icon", css].compact.join(" "),
                      "aria-hidden" => "true", focusable: "false", style: style do
      tag.use(href: "#i-#{name}")
    end
  end

  def nav_current?(path)
    request.path == path
  end

end
