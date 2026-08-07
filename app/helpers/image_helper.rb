# frozen_string_literal: true

# Responsive image delivery.
#
# `lib/tasks/images.rake` generates downscaled JPEG derivatives into
# app/assets/images/opt/ and records them in opt/manifest.json. This helper is
# the read side of that: it turns a plain asset name into an <img> with a
# srcset the browser can choose from, so a phone downloads ~60 KB instead of
# the 7.9 MB original.
#
#   = responsive_image_tag("SC24-26.jpg", alt: "Team UNM at the SC24 booth")
#
#   <img src="/assets/opt/SC24-26-1920w.jpg"
#        srcset="/assets/opt/SC24-26-640w.jpg 640w,
#                /assets/opt/SC24-26-1280w.jpg 1280w,
#                /assets/opt/SC24-26-1920w.jpg 1920w,
#                /assets/SC24-26.jpg 3500w"
#        sizes="100vw" width="3500" height="2333"
#        loading="lazy" decoding="async" alt="…">
#
# If an image has no derivatives (too small to be worth one, or a PNG whose
# transparency means it cannot be flattened to JPEG) this degrades to a plain
# image_tag at the original — so it is always safe to call.
module ImageHelper
  MANIFEST_PATH = "app/assets/images/opt/manifest.json"

  # source        asset name exactly as you would pass to image_tag / asset_path,
  #               e.g. "SC24-26.jpg". This is the manifest key.
  # alt:          required. Pass "" for decorative images.
  # sizes:        the slot's rendered width. Override this — "100vw" is the
  #               conservative default and over-fetches inside a narrow column.
  #               e.g. sizes: "(min-width: 60rem) 60rem, 100vw"
  # loading:      "lazy" by default; pass "eager" for anything above the fold.
  # decoding:     "async" by default.
  # html_options: anything else image_tag takes (class:, style:, data:, id:,
  #               explicit width:/height: to override the intrinsic ones, …).
  def responsive_image_tag(source, alt:, sizes: "100vw", loading: "lazy", decoding: "async", **html_options)
    entry = image_derivatives(source)

    options = { loading: loading, decoding: decoding }
    if entry
      options[:width]  = entry["width"]
      options[:height] = entry["height"]
    end
    options.merge!(html_options) # caller always wins
    options[:alt] = alt

    derivatives = entry ? entry["derivatives"] : nil
    return image_tag(source, options) if derivatives.blank?

    ordered = derivatives.sort_by { |width, _| width.to_i }
    candidates = ordered.map { |width, path| "#{path_to_image(path)} #{width}w" }
    candidates << "#{path_to_image(source)} #{entry['width']}w"

    options[:srcset] = candidates.join(", ")
    options[:sizes]  = sizes if sizes.present?

    image_tag(ordered.last[1], options)
  end

  # Manifest entry for one asset, or nil. Public so a caller can ask
  # "do derivatives exist?" without rendering anything.
  def image_derivatives(source)
    ImageHelper.manifest[source.to_s]
  end

  class << self
    # Cached, but re-read when the rake task rewrites the manifest so the dev
    # server picks up new derivatives without a restart.
    def manifest
      path  = Rails.root.join(MANIFEST_PATH)
      mtime = File.exist?(path) ? File.mtime(path) : nil

      if !defined?(@mtime) || @mtime != mtime
        @manifest = load_manifest(path, mtime)
        @mtime = mtime
      end

      @manifest
    end

    private

    def load_manifest(path, mtime)
      return {} if mtime.nil?

      JSON.parse(File.read(path))
    rescue JSON::ParserError, SystemCallError => e
      Rails.logger&.warn("[ImageHelper] unreadable #{MANIFEST_PATH}: #{e.message}")
      {}
    end
  end
end
