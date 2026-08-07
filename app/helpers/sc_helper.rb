module ScHelper
  # Data for the three Student Cluster Competition pages.
  #
  # HAML cannot hold a multi-line Ruby literal, so every list the SC
  # views iterate over lives here. Nothing in this file is presentation —
  # it is the page content, kept verbatim.

  # ── SC26 ────────────────────────────────────────────────────

  SC26_TIMELINE = [
    { date: "May 15",     labels: ["Application Deadline"], active: true },
    { date: "Jun 19",     labels: ["SC26 Teams Announced", "Cluster stand-up at UNM"] },
    { date: "Nov 6",      labels: ["Ship Cluster to Chicago"] },
    { date: "Nov 14",     labels: ["Cluster Setup in Chicago"] },
    { date: "Nov 16–18",  labels: ["Competition"] }
  ].freeze

  SC26_PEOPLE = [
    { title: "Team Manager", members: [
      { name: "Beckett Dunlavy", role: "Team Manager", photo: "SC26-beckett-dunlavy-headshot.jpeg", alt: "Beckett Dunlavy",
        url: "https://www.linkedin.com/in/beckettd/",
        bio: "Senior - Computer Science, incoming Software Engineer Intern at Tesla (ML & HPC Infra). Competed in indy-SC25 last year." }
    ] },
    { title: "Team", members: [
      { name: "Kiana Tarter", role: "Team Member", photo: "SC26-kianara-tarter.JPG", alt: "Kiana Tarter",
        url: "https://www.linkedin.com/in/kiana-m-t/", bio: nil },
      { name: "Ethan Hoover", role: "Team Member", photo: "SC26-ethan-hoover-headshot.jpg", alt: "Ethan Hoover",
        url: "https://www.linkedin.com/in/ethanhoover15/", bio: nil },
      { name: "Nevaeh Martinez", role: "Team Member", photo: "SC26-nevaeh-martinez-headshot.png", alt: "Nevaeh Martinez",
        url: "https://www.linkedin.com/in/nevaeh-martinez-4400b9380/", bio: nil },
      { name: "Amber Smith", role: "Team Member", photo: "SC26-amber-smith-headshot.png", alt: "Amber Smith",
        url: "https://www.linkedin.com/in/amber-smith-51875838b/", bio: nil },
      { name: "Abdullah Ismail", role: "Team Member", photo: "SC26-abdullah-ismail-headshot.jpeg", alt: "Abdullah Ismail",
        url: "https://www.linkedin.com/in/abdullah-ismail-7046342ab/", bio: nil }
    ] },
    { title: "Coaches", members: [
      { name: "Ryan Scherbarth", role: "Coach", photo: "Profile-05.jpg", alt: "Ryan Scherbarth",
        url: "/",
        bio: "Senior Software Engineer, AI/ML at NVIDIA. Led UNM's team at SC23 and SC24, and multiple other HPC competitions." },
      { name: "Alex Knigge", role: "Coach", photo: "SC26-alex-knigge-headshot.png", alt: "Alex Knigge",
        url: "https://www.linkedin.com/in/alex-knigge/",
        bio: "Software Engineer at Sandia National Laboratories (HPC monitoring & perf). Led UNM's team at SC25 and multiple other HPC competitions." },
      { name: "Dr. Matthew Fricke", role: "Faculty Advisor", photo: "SC26-matthew-fricke-headshot.jpeg", alt: "Matthew Fricke",
        url: "https://fricke.uk/",
        bio: "Research Associate Professor at the University of New Mexico, and faculty sponsor of UNM's HPC team since it's founding in 2023." }
    ] }
  ].freeze

  SC26_CLUSTER = [
    ["GPU",      "4× H200 NVL"],
    ["CPU",      "2× AMD EPYC 9455"],
    ["Memory",   "12× 48GB DDR5 / socket · 1.15TB / node"],
    ["Network",  "4× ConnectX-7 · 2-port · 400Gb/s / port"],
    ["Topology", "Switchless full mesh · direct P2P"]
  ].freeze

  # Rail index → legend caption. Colour comes from --rail-N.
  SC26_RAILS = [
    [0, "Rail 0 · CX7-0 · GPU 0"],
    [1, "Rail 1 · CX7-1 · GPU 1"],
    [2, "Rail 2 · CX7-2 · GPU 2"],
    [3, "Rail 3 · CX7-3 · GPU 3"]
  ].freeze

  SC26_POWER = [
    ["GPU · 4× H200 NVL @ rated TDP", "2,800W", "8,400W"],
    ["CPU · 2× EPYC 9455",            "580W",   "1,740W"],
    ["Memory · 24× 48GB DDR5",        "360W",   "1,080W"],
    ["Network · 4× ConnectX-7",       "100W",   "300W"],
    ["Board + misc",                  "150W",   "450W"]
  ].freeze

  SC26_POWER_CAPPED = [
    ["Non-GPU baseline (3 nodes)", "—",         "3,570W"],
    ["GPU · 12× @ 535W",           "535W each", "6,420W"]
  ].freeze

  # ── SC24 ────────────────────────────────────────────────────

  SC24_LINKS = [
    ["SC24 CARC Team Article",       "https://carc.unm.edu/news--events/News/sc24.html"],
    ["SCC24 Meet the Teams",         "https://sc24.supercomputing.org/2024/09/teams-compete-in-the-ultimate-hpc-challenge-at-sc24/"],
    ["SCC24 Conference Team Site",   "https://sc24.supercomputing.org/students/student-cluster-competition/"]
  ].freeze

  SC24_CLUSTER = [
    ["Nodes",   "3×"],
    ["CPU",     "2× Intel Xeon Platinum 8580"],
    ["Memory",  "64 GB × 32 DDR5-5600"],
    ["GPU",     "4× Nvidia H100 NVL"],
    ["Network", "4× Nvidia ConnectX-7 NIC"]
  ].freeze

  # The shoots. These are no longer four labelled sections on the page —
  # they survive only as the grouping that tells each frame which alt it
  # owns, and are concatenated in this order into the one pool below.
  SC24_SETS = [
    { title: "Competition Photos", meta: "Atlanta · 11/2024",
      alt: "Ryan Scherbarth at SC24 HPC Student Cluster Competition, Atlanta 2024",
      images: %w[SC24-25.jpg SC24-35.jpeg SC24-28.jpeg SC24-29.jpeg SC24-33.jpeg SC24-34.jpeg SC24-30.jpeg SC24-31.jpeg] },
    { title: "Team Photos", meta: "Atlanta · 11/2024",
      alt: "Ryan Scherbarth Team UNM SC24 HPC Student Cluster Competition",
      images: %w[SC24-26.jpg SC24-23.jpg SC24-24.jpg SC24-27.jpg SC24-32.jpeg SC24-01.jpeg SC24-03.jpeg] },
    { title: "Shipping Cluster", meta: "Atlanta · 11/2024",
      alt: "Ryan Scherbarth SC24 HPC cluster shipping, Team UNM",
      images: %w[SC24-19.png SC24-18.png SC24-20.png SC24-21.png SC24-22.MOV] },
    { title: "Cluster Build", meta: "Atlanta · 11/2024",
      alt: "Ryan Scherbarth SC24 HPC cluster build, Team UNM",
      images: %w[SC24-16.jpeg SC24-07.jpeg SC24-04.jpeg SC24-08.jpeg SC24-09.jpeg SC24-10.jpeg SC24-11.jpeg SC24-12.jpeg SC24-13.jpeg SC24-14.jpeg SC24-15.jpeg SC24-17.MOV] }
  ].freeze

  # The page's one plate: every SC24 frame there is, in set order, each
  # carrying the alt of the shoot it came from. `photo_mosaic` packs
  # `images:` onto the sheet; `title:` / `meta:` are what the viewer prints
  # in its head, and are the only place those words still appear — the
  # sheet itself is unlabelled.
  SC24_POOL = {
    title: "Team UNM · SC24",
    meta: "Atlanta · 11/2024",
    alt: "Ryan Scherbarth at SC24 HPC Student Cluster Competition, Atlanta 2024",
    images: SC24_SETS.flat_map { |set| set[:images].map { |file| [file, set[:alt]] } }
  }.freeze

  SC24_CHARTS = [
    ["H100-01.png", "H100 chart 1"],
    ["H100-02.png", "H100 chart 2"],
    ["H100-03.png", "H100 chart 3"]
  ].freeze

  SC24_POSTER_PDF = "https://www.dropbox.com/scl/fi/aa3yegenjlusvvb7qwnkv/UNM-SC24-Poster.pdf?rlkey=9aqbfl3zqcrft5zzcs73az4af&st=vkg4ll5x&dl=0".freeze

  # ── SC23 ────────────────────────────────────────────────────

  SC23_LINKS = [
    ["SCC23 Conference Team Site",  "https://www.studentclustercompetition.us/2023/Teams/NewMexico/index.html"],
    ["SCC23 Competition Site",      "https://www.studentclustercompetition.us/2023/index.html"],
    ["UNM Roadrunners Team Site",   "https://roadrunners.cs.unm.edu/"]
  ].freeze

  SC23_PHOTOS = %w[
    SC23-06.jpeg SC23-01.jpeg SC23-02.jpeg SC23-03.jpeg SC23-04.jpg
    SC23-05.jpeg SC23-07.jpeg SC23-08.jpeg SC23-09.jpeg
  ].freeze

  SC23_PHOTO_ALT = "Ryan Scherbarth at SC23 HPC Student Cluster Competition, Denver 2023".freeze

  # The page's one plate, in the shape `photo_mosaic` packs.
  SC23_SET = {
    title: "Competition Photos",
    meta: "Denver · 11/2023",
    alt: SC23_PHOTO_ALT,
    images: SC23_PHOTOS
  }.freeze

  SC23_POSTER_PDF = "https://www.dropbox.com/scl/fi/yl7cvamao76y4biv2hiky/SC23Poster.pdf?rlkey=wefdxtu024bplxmh1uxn12ihy&st=1dh4posj&dl=0".freeze

  def sc26_timeline
    SC26_TIMELINE
  end

  def sc26_people
    SC26_PEOPLE
  end

  def sc26_cluster
    SC26_CLUSTER
  end

  def sc26_rails
    SC26_RAILS
  end

  def sc26_power
    SC26_POWER
  end

  def sc26_power_capped
    SC26_POWER_CAPPED
  end

  def sc24_links
    SC24_LINKS
  end

  def sc24_cluster
    SC24_CLUSTER
  end

  def sc24_pool
    SC24_POOL
  end

  def sc24_charts
    SC24_CHARTS
  end

  def sc24_poster_pdf
    SC24_POSTER_PDF
  end

  def sc23_links
    SC23_LINKS
  end

  def sc23_set
    SC23_SET
  end

  def sc23_poster_pdf
    SC23_POSTER_PDF
  end
end
