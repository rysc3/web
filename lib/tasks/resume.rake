# Renders the resume PDF to a flat image.
#
# The browser's PDF reader cannot be styled from outside: it paints its own
# grey field around the page, adds a toolbar, and ignores every attempt to
# make the document fill its frame. A one-page resume does not need a
# reader — it needs to be legible. So the page is rasterised here and the
# PDF stays available as the download.
#
# Re-run after replacing the PDF:  bundle exec rake resume:render
namespace :resume do
  SOURCE = "public/Ryan Scherbarth - Resume.pdf".freeze
  TARGET = "app/assets/images/resume-page.png".freeze

  desc "Rasterise the resume PDF to app/assets/images/resume-page.png"
  task :render do
    abort "missing #{SOURCE}" unless File.exist?(SOURCE)

    tmp = Dir.mktmpdir
    # qlmanage is the only PDF rasteriser on a stock macOS box — no
    # ImageMagick, no Ghostscript, no pdftoppm.
    system("qlmanage", "-t", "-s", "2000", "-o", tmp, SOURCE,
           out: File::NULL, err: File::NULL)

    rendered = Dir[File.join(tmp, "*.png")].first
    abort "qlmanage produced nothing" unless rendered

    FileUtils.cp(rendered, TARGET)
    FileUtils.remove_entry(tmp)

    puts "#{TARGET} — #{(File.size(TARGET) / 1024.0).round} KB"
  end
end
