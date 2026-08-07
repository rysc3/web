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
    { label: "Stack Overflow", icon: "stackoverflow", url: "https://stackoverflow.com/users/20306478/ry-sch" },
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

  # Initials for an organisation that has no logo file. Drops the noise
  # words so "International Conference for Performance Engineering (ICPE)"
  # reads as ICPE rather than ICFPE.
  ORG_STOPWORDS = %w[the of for and a an at in on to].freeze

  def org_monogram(org)
    return "" if org.blank?

    # An explicit acronym in parentheses always wins.
    if (paren = org[/\(([A-Z0-9]{2,6})\)/, 1])
      return paren
    end

    words = org.gsub(/[^A-Za-z0-9 ]/, " ").split
                .reject { |w| ORG_STOPWORDS.include?(w.downcase) }

    # A word that is already an acronym or a code (SC26, UNM, NASA, ICPE).
    if (code = words.find { |w| w.match?(/\A[A-Z]{2,}[0-9]*\z/) })
      return code[0, 4]
    end

    words.first(3).map { |w| w[0] }.join.upcase
  end
end
