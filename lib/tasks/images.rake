# frozen_string_literal: true
#
# Responsive image derivatives for app/assets/images.
#
#   rake images:optimize                       # inside the app (needs macOS host)
#   rake -f lib/tasks/images.rake images:optimize   # standalone, no Rails/bundler
#
# The image pipeline is macOS-only: it shells out to `sips`, which is the only
# raster tool available on this machine (no ImageMagick / cwebp / ffmpeg / node).
# The Rails container is Linux and has no `sips`, so this task is run on the
# HOST; the repo is bind-mounted into the container, so the output shows up
# there immediately. That is why nothing here touches Rails — it must boot under
# plain system ruby.
#
# Notes on sips, all verified on this machine rather than assumed:
#   * `sips -s format webp` does NOT work. It fails with
#     "Can't write format: org.webmproject.webp" and writes no file, so WebP /
#     AVIF are off the table entirely and every derivative is JPEG.
#   * `-Z` (resampleHeightWidthMax) UPSCALES images that are already smaller
#     than the target, so we compare against the real pixel width first and
#     use `--resampleWidth`, which constrains width (what `srcset` w-descriptors
#     actually mean) and preserves aspect ratio.
#   * `sips -g hasAlpha` reports "yes" for every PNG here, including plain
#     photographs, because it only reflects the PNG colour type. It cannot be
#     used to decide whether flattening to JPEG is safe, so this file decodes
#     the PNG and looks at the actual alpha samples (see `png_opaque?`).
#
# NON-DESTRUCTIVE: originals are only ever read. Everything is written to
# app/assets/images/opt/.

require "json"
require "zlib"
require "fileutils"
require "shellwords"

module ImageDerivatives
  ROOT      = File.expand_path("../../app/assets/images", __dir__)
  OPT_DIR   = File.join(ROOT, "opt")
  MANIFEST  = File.join(OPT_DIR, "manifest.json")

  # Derivative widths. 640 covers phones, 1280 covers most laptop-sized
  # gallery slides, 1920 covers full-bleed on a 1x desktop / 2x phone.
  WIDTHS    = [640, 1280, 1920].freeze
  QUALITY   = 70        # sips formatOptions, 0-100
  MIN_BYTES = 300_000   # anything smaller is not worth a derivative

  RASTER = %w[.jpg .jpeg .png].freeze

  module_function

  def run(widths: WIDTHS, quality: QUALITY, min_bytes: MIN_BYTES, force: false)
    abort "sips not found — this task only runs on macOS." unless system("which sips > /dev/null 2>&1")
    abort "no such directory: #{ROOT}" unless Dir.exist?(ROOT)

    FileUtils.mkdir_p(OPT_DIR)

    manifest      = {}
    written       = 0
    skipped_fresh = 0
    src_bytes     = 0   # originals of images we made derivatives for
    deriv_bytes   = 0   # every derivative on disk after this run
    before_1280   = 0   # what a 1280-wide slot used to cost...
    after_1280    = 0   # ...and what it costs now

    sources.each do |rel|
      abs  = File.join(ROOT, rel)
      w, h = dimensions(abs)
      next unless w && h

      entry = { "width" => w, "height" => h, "derivatives" => {} }

      if eligible?(abs, min_bytes)
        widths.each do |tw|
          next if tw >= w # never upscale; the original already covers this width

          out_rel = derivative_rel(rel, tw)
          out_abs = File.join(ROOT, out_rel)

          if force || stale?(out_abs, abs)
            FileUtils.mkdir_p(File.dirname(out_abs))
            if resize(abs, out_abs, tw, quality)
              written += 1
              puts format("  + %-46s %8s -> %8s", out_rel, human(File.size(abs)), human(File.size(out_abs)))
            else
              warn "  ! failed: #{rel} @ #{tw}w"
              next
            end
          else
            skipped_fresh += 1
          end

          entry["derivatives"][tw.to_s] = out_rel if File.exist?(out_abs)
        end
      end

      unless entry["derivatives"].empty?
        src_bytes   += File.size(abs)
        deriv_bytes += entry["derivatives"].values.sum { |p| File.size(File.join(ROOT, p)) }
        best = entry["derivatives"]["1280"] || entry["derivatives"].values.last
        before_1280 += File.size(abs)
        after_1280  += File.size(File.join(ROOT, best))
      end

      manifest[rel] = entry
    end

    File.write(MANIFEST, JSON.pretty_generate(manifest) << "\n")

    covered = manifest.count { |_, e| !e["derivatives"].empty? }
    puts
    puts "images:optimize"
    puts "  catalogued        #{manifest.size} raster images (manifest: #{rel_to_root(MANIFEST)})"
    puts "  with derivatives  #{covered}"
    puts "  written this run  #{written}   (up to date, skipped: #{skipped_fresh})"
    puts "  originals         #{human(src_bytes)}"
    puts "  all derivatives   #{human(deriv_bytes)}"
    puts "  1280w delivery    #{human(before_1280)} -> #{human(after_1280)}   #{pct(before_1280, after_1280)} smaller"
    puts
  end

  # --- discovery ------------------------------------------------------------

  def sources
    Dir.glob("**/*", base: ROOT)
       .reject { |rel| rel.start_with?("opt/", ".") }
       .select { |rel| RASTER.include?(File.extname(rel).downcase) }
       .select { |rel| File.file?(File.join(ROOT, rel)) }
       .sort
  end

  # Big enough to bother with, and safe to flatten onto an opaque JPEG.
  def eligible?(abs, min_bytes)
    return false if File.size(abs) < min_bytes
    return true  unless File.extname(abs).casecmp(".png").zero?

    png_opaque?(abs)
  end

  def stale?(out_abs, src_abs)
    !File.exist?(out_abs) || File.mtime(out_abs) < File.mtime(src_abs)
  end

  def derivative_rel(rel, width)
    dir  = File.dirname(rel)
    base = File.basename(rel, File.extname(rel))
    name = "#{base}-#{width}w.jpg"
    dir == "." ? File.join("opt", name) : File.join("opt", dir, name)
  end

  # --- sips -----------------------------------------------------------------

  def dimensions(abs)
    out = `sips -g pixelWidth -g pixelHeight #{Shellwords.escape(abs)} 2>/dev/null`
    w = out[/pixelWidth:\s*(\d+)/, 1]
    h = out[/pixelHeight:\s*(\d+)/, 1]
    w && h ? [w.to_i, h.to_i] : nil
  end

  def resize(src, dest, width, quality)
    cmd = [
      "sips", "--resampleWidth", width.to_s,
      "-s", "format", "jpeg",
      "-s", "formatOptions", quality.to_s,
      src, "--out", dest
    ].shelljoin
    system("#{cmd} > /dev/null 2>&1") && File.exist?(dest) && File.size(dest).positive?
  end

  # --- PNG alpha ------------------------------------------------------------

  # True when no pixel in the PNG is anything other than fully opaque, i.e.
  # flattening it into a JPEG cannot change what the user sees. Anything we
  # cannot prove opaque (interlaced, 16-bit, palette+tRNS, malformed) returns
  # false and is simply left alone — the helper falls back to the original.
  def png_opaque?(path)
    data = File.binread(path)
    return false unless data.byteslice(1, 3) == "PNG"

    width     = data.byteslice(16, 4).unpack1("N")
    height    = data.byteslice(20, 4).unpack1("N")
    depth     = data.getbyte(24)
    ctype     = data.getbyte(25)
    interlace = data.getbyte(28)

    return true  if ctype == 0 || ctype == 2 # greyscale / truecolour: no alpha channel exists
    return false unless (ctype == 4 || ctype == 6) && depth == 8 && interlace.zero?

    bpp    = ctype == 6 ? 4 : 2
    stride = width * bpp

    idat = +"".b
    off  = 8
    while off + 8 <= data.bytesize
      len  = data.byteslice(off, 4).unpack1("N")
      type = data.byteslice(off + 4, 4)
      break if type == "IEND"

      idat << data.byteslice(off + 8, len) if type == "IDAT"
      off += 12 + len
    end
    return false if idat.empty?

    raw  = Zlib::Inflate.inflate(idat)
    prev = ("\0".b * stride)
    pos  = 0

    height.times do
      filter = raw.getbyte(pos)
      pos += 1
      row = raw.byteslice(pos, stride).unpack("C*")
      pos += stride
      return false if row.size < stride

      unfilter!(row, prev, filter, bpp, stride)

      i = bpp - 1
      while i < stride
        return false unless row[i] == 255

        i += bpp
      end
      prev = row.pack("C*")
    end

    true
  rescue StandardError
    false
  end

  # PNG scanline reconstruction (RFC 2083 §6), in place.
  def unfilter!(row, prev, filter, bpp, stride)
    case filter
    when 1 # Sub
      (bpp...stride).each { |i| row[i] = (row[i] + row[i - bpp]) & 0xff }
    when 2 # Up
      (0...stride).each { |i| row[i] = (row[i] + prev.getbyte(i)) & 0xff }
    when 3 # Average
      (0...stride).each do |i|
        left = i >= bpp ? row[i - bpp] : 0
        row[i] = (row[i] + ((left + prev.getbyte(i)) >> 1)) & 0xff
      end
    when 4 # Paeth
      (0...stride).each do |i|
        a = i >= bpp ? row[i - bpp] : 0
        b = prev.getbyte(i)
        c = i >= bpp ? prev.getbyte(i - bpp) : 0
        p = a + b - c
        pa = (p - a).abs
        pb = (p - b).abs
        pc = (p - c).abs
        row[i] = (row[i] + (pa <= pb && pa <= pc ? a : (pb <= pc ? b : c))) & 0xff
      end
    end
  end

  # --- output ---------------------------------------------------------------

  def human(bytes)
    return "#{bytes} B" if bytes < 1024

    units = %w[KB MB GB]
    value = bytes.to_f
    unit  = nil
    units.each do |u|
      value /= 1024
      unit = u
      break if value < 1024
    end
    format("%.1f %s", value, unit)
  end

  def pct(before, after)
    return "0%" if before.zero?

    format("%.1f%%", (1 - after.to_f / before) * 100)
  end

  def rel_to_root(abs)
    abs.sub("#{File.expand_path('../..', __dir__)}/", "")
  end
end

namespace :images do
  desc "Generate responsive JPEG derivatives in app/assets/images/opt (macOS only; FORCE=1 to rebuild)"
  task :optimize do
    ImageDerivatives.run(
      widths: (ENV["WIDTHS"] || "").split(",").map(&:to_i).reject(&:zero?).then { |w| w.empty? ? ImageDerivatives::WIDTHS : w },
      quality: (ENV["QUALITY"] || ImageDerivatives::QUALITY).to_i,
      min_bytes: (ENV["MIN_BYTES"] || ImageDerivatives::MIN_BYTES).to_i,
      force: ENV["FORCE"] == "1"
    )
  end
end
