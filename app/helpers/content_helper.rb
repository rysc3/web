# Data layer for the home page. HAML cannot hold multi-line Ruby literals,
# so every list the index view iterates over lives here.
#
# Convention: `desc` may contain literal HTML and is rendered with raw() —
# that is the only field where an entity like &amp; belongs. Every other
# field is escaped by the view, so it carries a real "&".
module ContentHelper
  # 02 · Trajectory — newest year first, entries newest first within a year.
  #
  # `mark` is the set monogram for an organisation with no logo file —
  # a generic initialiser gets these wrong (Winter Classic Invitational
  # HPC would come out "HPC"), so they are stated.
  #
  # `tenure` groups consecutive roles at one employer into a single run on
  # the timeline. Two Tesla rows are not two jobs — they are one stretch
  # with a promotion in it, and the chart should say so.
  #
  # `dates` is the human string and is what renders. `start`/`end` are the
  # machine reading of that same string, used only to place the entry on the
  # timeline axis — "YYYY-MM", inclusive of the end month, nil end = ongoing.
  # The irregular ones are read generously: a lone month is a one-month span,
  # and "Spring & Fall 2024" is the whole of 2024.
  CAREER_CHAPTERS = [
    { year: 2026, entries: [
      { track: "professional", title: "Sr. Software Engineer", org: "Nvidia", dates: "July 2026 — Present", start: "2026-07", end: nil, logo: "nvidia_logo.png", alt: "Nvidia",
        # `desc` takes either a single string or a list of paragraphs.
        desc: [
          "New cluster builds &amp; performance optimization for next-generation hyperscale deployments.",
          '<a href="https://developer.nvidia.com/blog/inside-the-nvidia-rubin-platform-six-new-chips-one-ai-supercomputer/" target="_blank" rel="noopener">NVIDIA Vera Rubin platform</a>.'
        ],
        media: [
          { file: "nvidia-1.png", alt: "Nvidia Vera Rubin Platform"}
        ] },
      { track: "extracurricular", title: "Team Coach", org: "SC26 Student Cluster Competition", dates: "April 2026 — Present", start: "2026-04", end: nil,
        desc: '<a href="/sc26">SC26 Team Site.</a>' },
      { track: "extracurricular", title: "Online Conference Chair", org: "Hot Interconnects 2026", dates: "January 2026 — Present", start: "2026-01", end: nil,
        desc: '<a href="https://hoti.org/2026/committees.html" target="_blank" rel="noopener">HotI 2026 Committees.</a>' }
    ] },
    { year: 2025, entries: [
      { track: "professional", title: "Sr. Software Engineer", org: "Tesla", dates: "December 2025 — July 2026", start: "2025-12", end: "2026-07", logo: "tesla_logo_2.png", alt: "Tesla", tenure: "tesla",
        desc: 'More ml &amp; more hpc infra for tesla ap' },
      { track: "professional", title: "Software Engineer", org: "Tesla", dates: "January 2025 — December 2025", start: "2025-01", end: "2025-12", logo: "tesla_logo_2.png", alt: "Tesla", tenure: "tesla",
        desc: 'Machine learning &amp; HPC infrastructure for Tesla Autopilot.',
        media: [
          { file: "tesla-2.jpeg", alt: "Tesla AI Training Capacity Ramp" },
          { file: "tesla-3.jpeg", alt: "Tesla Cortex - Tesla Supercomputer (Nvidia H100)" },
          { file: "tesla-1.jpeg", alt: "Tesla Cortex 2 - Tesla Supercomputer (Nvidia GB300)" },
        ] },
      { track: "extracurricular", title: "Student Cluster Competition Committee", org: "SC25 HPC Student Cluster Competition", dates: "January 2025 — November 2025", start: "2025-01", end: "2025-11",
        desc: '<a href="https://sc25.supercomputing.org/planning-committee/" target="_blank" rel="noopener">SC25 Conference Committee.</a>' }
    ] },
    { year: 2024, entries: [
      { track: "extracurricular", title: "Student Volunteer", org: "PEARC24 Conference", dates: "July 2024", start: "2024-07", end: "2024-07",
        desc: '<a href="https://pearc.acm.org/" target="_blank" rel="noopener">PEARC conference series.</a>' },
      { track: "extracurricular", title: "Team Manager", org: "SC24 HPC Student Cluster Competition", dates: "June 2024 — December 2024", start: "2024-06", end: "2024-12",
        desc: '<a href="/sc24">SC24 Team Site</a>.' },
      { track: "extracurricular", title: "Project Evaluation Committee Member", org: "NM Supercomputing Challenge", dates: "February 2024", start: "2024-02", end: "2024-02",
        desc: '<a href="https://supercomputingchallenge.org/23-24/evaluations-schedule" target="_blank" rel="noopener">Supercomputing Challenge website.</a>' },
      { track: "professional", title: "Teaching Assistant — CS491", org: "The University of New Mexico", dates: "Spring & Fall 2024", start: "2024-01", end: "2024-12", logo: "unm_mark.png", alt: "UNM",
        desc: 'Teaching Assistant for CS491: High Performance Computing. <a href="https://carc.unm.edu/news--events/News/hpc-course-matthew.html" target="_blank" rel="noopener">(Course intro article)</a>.',
        media: [
          { file: "carc-1.png", alt: "CARC High Performance Computing Workshop (Dr. Fricke)"}
          ] },
      { track: "extracurricular", title: "Team Manager", org: "Winter Classic Invitational HPC 2024", dates: "January 2024 — May 2024", start: "2024-01", end: "2024-05",
        desc: '<a href="https://www.winterclassicinvitational.com/team/university-of-new-mexico-lobo24/" target="_blank" rel="noopener">View team site.</a>' },
      { track: "extracurricular", title: "Member of Artifact Evaluation Committee", org: "International Conference for Performance Engineering (ICPE)", dates: "January 2024 — May 2024", start: "2024-01", end: "2024-05",
        desc: '<a href="https://icpe2024.spec.org/program-committee/" target="_blank" rel="noopener">2024 ICPE committee.</a>' },
      { track: "extracurricular", title: "Team Manager", org: "ISC24 Virtual HPC Student Cluster Competition", dates: "January 2024 — April 2024", start: "2024-01", end: "2024-04",
        desc: '<a href="https://www.isc-hpc.com/student-cluster-competition-2024.html" target="_blank" rel="noopener">Competition site.</a>' }
    ] },
    { year: 2023, entries: [
      { track: "extracurricular", title: "Team Manager", org: "SC23 HPC Student Cluster Competition", dates: "August 2023 — December 2023", start: "2023-08", end: "2023-12",
        desc: '<a href="/sc23">SC23 Team Site</a>.' },
      { track: "professional", title: "HPC Systems Specialist", org: "Center for Advanced Research Computing — UNM", dates: "May 2023 — December 2024", start: "2023-05", end: "2024-12", logo: "carc_logo_transparent.png", alt: "CARC",
        desc: 'Supporting users on UNM HPC clusters, benchmarking, profiling, and reporting. <a href="https://carc.unm.edu/news--events/News/fall-23-undergrads.html" target="_blank" rel="noopener">(CARC Article)</a>.',
        media: [
          { file: "carc-2.png", alt: "Center for Advanced Reserach Computing Team"}
        ] },
      { track: "extracurricular", title: "Peer Mentor", org: "UNM School of Engineering", dates: "January 2023 — December 2024", start: "2023-01", end: "2024-12",
        desc: '<a href="https://ess.unm.edu/about-us/index.html" target="_blank" rel="noopener">UNM Engineering Student Success Center (ESS).</a>' },
      { track: "extracurricular", title: "Team Manager", org: "Winter Classic Invitational HPC 2023", dates: "January 2023 — May 2023", start: "2023-01", end: "2023-05",
        desc: '<a href="https://www.winterclassicinvitational.com/team/university-of-new-mexico/" target="_blank" rel="noopener">Team site</a>.' }
    ] },
    { year: 2022, entries: [
      { track: "extracurricular", title: "Machine Learning Team", org: "NASA Minds Team Chili House", dates: "November 2022 — May 2023", start: "2022-11", end: "2023-05",
        desc: '<a href="https://drive.google.com/file/d/1lyjeK7hHzxfpkWrZFMXKVdWN3r56dOvG/view" target="_blank" rel="noopener">Preliminary Design Review (PDR)</a>.' },
      { track: "professional", title: "Software Engineer, HPC", org: "Sandia National Laboratories", dates: "October 2022 — December 2024", start: "2022-10", end: "2024-12", logo: "sandia_mark.png", alt: "Sandia",
        desc: 'Design, acquisition, deployment, and optimization of large-scale scientific HPC clusters. Full stack web in Ruby on Rails. <a href="https://hpc.sandia.gov/sandia-national-labs-high-performance-computing/hpc-production-clusters/" target="_blank" rel="noopen">(Sandia HPC Capacity Cluster Platforms)</a>.',
        media: [
          { file: "snl-team-photo.jpeg", alt: "Sandia National Laboratories 9320: HPC &amp Mission Computing, July 17 2023"}
        ] },
      { track: "professional", title: "Software Engineer Intern", org: "Air Force Research Laboratory", dates: "August 2022 — December 2022", start: "2022-08", end: "2022-12", logo: "afrl_logo.png", alt: "AFRL",
        desc: "Cyber Resilience Team, Space Vehicles Directorate at Kirtland Air Force Base." },
      # The degree is the one entry that belongs under both pills — it is the
      # thing the professional record was built on and the thing every
      # extracurricular hung off. `track` stays singular because it still
      # decides the bar's colour and its place in the lane packing; `tracks`
      # is only what the filter matches against, and it defaults to [track]
      # for every other entry.
      # Carries a logo despite not being a job — the same exception as `tracks`
      # above, and for the same reason. Uses the identical mark as the CS491
      # entry so the two UNM rows line up.
      { track: "extracurricular", tracks: %w[professional extracurricular],
        title: "B.S. Computer Science w/ Minor in Mathematics", org: "The University of New Mexico", dates: "August 2022 — December 2024", start: "2022-08", end: "2024-12",
        logo: "unm_mark.png", alt: "UNM",
        desc: nil }
    ] }
  ].freeze

  # 03 · Elsewhere — the six bento panels.
  HOME_PANELS = [
    # SC26 has no photography yet — its identity mark gets printed on stock
    # instead of being cropped like a photograph.
    { href: "/sc26",    title: "SC26",    sub: "HPC Student Cluster Competition", img: "SC26-01.png", mark: true },
    { href: "/sc24",    title: "SC24",    sub: "HPC Student Cluster Competition", img: "SC24-33.jpeg" },
    { href: "/sc23",    title: "SC23",    sub: "HPC Student Cluster Competition", img: "SC23-06.jpeg" },
    { href: "/resume",  title: "Resume",  sub: "Experience & education",          img: "Profile-01.jpg" },
    { href: "/meet",    title: "Meet",    sub: "Book a meeting",                  img: "SC24-14.jpeg" },
    { href: "/courses", title: "Courses", sub: "Course history",                  img: "Profile-03.jpeg" }
  ].freeze

  # 04 · Archive — [date, title, href].
  ARCHIVE_ENTRIES = [
    ["5/18/2025",  "Website Deepwiki",                                          "https://deepwiki.com/rysc3/web/1-overview"],
    ["4/7/2025",   "SC25 Competition Intro / Overview",                         "https://sc25.supercomputing.org/wp-content/uploads/2025/04/sc25_webinar01.pdf"],
    ["2/21/2025",  "CARC Quantum Brochure",                                     "https://www.dropbox.com/scl/fi/1pwtxjcu842j58uwxc1g9/carc_brochure.pdf?rlkey=aaumu5z1pnqubv04ulyc20y4w&st=dwe4oml2&dl=0"],
    ["2/19/2025",  "CIQ @ SC24 Article",                                        "https://ciq.com/blog/educating-the-next-generation-of-hpc-engineers-with-open-source-tools/"],
    ["2/1/2025",   "SC25 Student Cluster Competition Committee",                "https://sc25.supercomputing.org/planning-committee/"],
    ["12/23/2024", "Graduation Program",                                        "https://graduation.unm.edu/fa24ug/program/_bachelors.html"],
    ["12/11/2024", "UNM HPC Team Article",                                      "https://engineering.unm.edu/news/2024/12/partnering-for-success-computer-science-students-represent-unm-in-nasa-and-supercomputing-competitions.html"],
    ["10/5/2024",  "UNM Newsroom SC24 Article",                                 "https://news.unm.edu/news/carc-team-gears-up-for-sc24-competition"],
    ["10/2/2024",  "SC24 CARC Team Article",                                    "https://carc.unm.edu/news--events/News/sc24.html"],
    ["9/11/2024",  "SC24 Cluster Build",                                        "/sc24"],
    ["9/7/2024",   "SC24 Meet the Teams",                                       "https://sc24.supercomputing.org/2024/09/teams-compete-in-the-ultimate-hpc-challenge-at-sc24/"],
    ["5/31/2024",  "2018 Tesla Model S P100D sentry mode battery drain",        "/tesla_battery"],
    ["5/15/2024",  "ASU Profile",                                               "https://search.asu.edu/profile/4267690"],
    ["5/10/2024",  "2024 Winter Classic HPC Results",                           "https://www.youtube.com/watch?v=SURm-vMrFV8&ab_channel=StudentClusterCompetitions"],
    ["5/10/2024",  "2024 Winter Classic Invitational HPC Competition",          "https://www.winterclassicinvitational.com/team/university-of-new-mexico-lobo24/"],
    ["5/5/2024",   "Member of ICPE Artifact Review Committee",                  "https://icpe2024.spec.org/program-committee/"],
    ["4/5/2024",   "CS491 Project 2: High Performance Conjugate Gradients",     "https://fricke.co.uk/Teaching/CS491_2024/Assignments/HPC_Project2.pdf"],
    ["4/1/2024",   "ISC24 Student Cluster Competition Team",                    "https://www.hpcadvisorycouncil.com/events/student-cluster-competition/team-unm.php"],
    ["2/26/2024",  "Tilted fricke.uk",                                          "https://github.com/rysc3/fricke.uk"],
    ["2/15/2024",  "CS491 Project 1: High Performance Linpack",                 "https://fricke.co.uk/Teaching/CS491_2024/Assignments/HPC_Project1.pdf"],
    ["2/13/2024",  "West Big Data Innovation Hub SC23 Article",                 "https://www.westbigdatahub.org/post/two-western-states-teams-compete-in-student-cluster-competition-at-sc2023-in-denver_"],
    ["2/13/2024",  "Judge for New Mexico Consortium Supercomputing Challenge",  "https://supercomputingchallenge.org/23-24/evaluations-schedule"],
    ["1/20/2024",  "TA for CS491 HPC Course",                                   "https://fricke.co.uk/Teaching/CS491_2024/HPC_Course_Syllabus.pdf"],
    ["1/3/2024",   "Penguin Solutions Article, SC23 Competition",               "https://medium.com/@penguinsolutions/student-cluster-competition-team-the-roadrunners-sponsored-by-penguin-solutions-at-sc23-e265233c8cff"],
    ["12/3/2023",  "UNM CARC SC23 Team Article",                                "https://carc.unm.edu/news--events/News/sc23-conference.html"],
    ["11/23/2023", "UNM HPC Roadrunners Team Site",                             "https://roadrunners.cs.unm.edu/"],
    ["11/20/2023", "Penguin Solutions SC23 Team Sponsorship Article",           "https://www.penguinsolutions.com/company/resources/newsroom/student-cluster-competition-team-the-roadrunners-sponsored-by-penguin-solutions-at-sc23"],
    ["10/22/2023", "Duke City Marathon",                                        "https://www.athlinks.com/event/35398/results/Event/1063165/Course/2408972/Bib/54"],
    ["8/7/2023",   "SC23 Student Cluster Competition Team",                     "https://sc23.supercomputing.org/2023/08/meet-this-years-scc-teams/"],
    ["5/5/2023",   "UNM Outstanding Sophomore Award",                           "https://engineering.unm.edu/awards/annual-awards-2023.pdf"],
    ["5/1/2023",   "UNM CARC Employee Article",                                 "https://carc.unm.edu/news--events/News/fall-23-undergrads.html"],
    ["4/10/2023",  "UNM CARC HPC Team Article",                                 "https://carc.unm.edu/news--events/News/hpc-competitions-2023.html"],
    ["3/30/2023",  "2023 Winter Classic Invitational HPC Competition",          "https://www.winterclassicinvitational.com/team/university-of-new-mexico/"],
    ["3/3/2023",   "UNM CS Founding UNM HPC Team",                              "https://www.cs.unm.edu/news/2023/03/unm-computer-science-students-take-part-in-hpc-competition.html"],
    ["3/2/2023",   "UNM News Founding UNM HPC Team",                            "https://news.unm.edu/news/computer-science-students-take-part-in-hpc-competition"],
    ["1/25/2023",  "NASA Minds Team Chilihouse",                                "https://drive.google.com/file/d/1lyjeK7hHzxfpkWrZFMXKVdWN3r56dOvG/view"],
    ["10/16/2022", "Duke City Half Marathon",                                   "https://www.athlinks.com/event/35398/results/Event/1032202/Course/2296577/Bib/1417"],
    ["3/3/2023",   "Website History",                                           "https://web.archive.org/web/20251115000000*/ryanscherbarth.com"]
  ].freeze

  # 05 · Plates — one gallery per plate.
  # `images:` entries are either "file.jpg" — inheriting the plate's alt —
  # or ["file.jpg", "its own alt"] where the original page described that
  # frame specifically. The results screenshots must not be announced as
  # action photographs.
  PHOTO_PLATES = [
    { title: "SC24 HPC Competition", meta: "Atlanta · 11/2024", href: "/sc24",
      alt: "Ryan Scherbarth at SC24 HPC Student Cluster Competition, Atlanta 2024",
      images: ["SC24-35.jpeg",
               "SC24-33.jpeg",
               "SC24-34.jpeg",
               "SC24-27.jpg",
               "SC24-28.jpeg",
               "SC24-29.jpeg",
               "SC24-24.jpg",
               "SC24-08.jpeg",
               "SC24-14.jpeg",
               "SC24-07.jpeg"] },
    { title: "PEARC24 HPC Conference", meta: "07/2024", href: "https://pearc.acm.org/",
      alt: "Ryan Scherbarth at PEARC24 HPC Conference 2024",
      images: %w[PEARC24-06.jpeg PEARC24-01.jpeg PEARC24-02.jpeg] },
    { title: "RMACC HPC Conference", meta: "05/2024", href: "https://rmacc.org/about-us",
      alt: "Ryan Scherbarth at RMACC HPC Conference 2024",
      images: %w[RMACC24-01.jpeg RMACC24-02.jpeg RMACC24-03.jpeg] },
    { title: "SC23 HPC Competition", meta: "Denver · 11/2023", href: "/sc23",
      alt: "Ryan Scherbarth at SC23 HPC Student Cluster Competition, Denver 2023",
      images: %w[SC23-04.jpg SC23-01.jpeg SC23-02.jpeg SC23-03.jpeg SC23-06.jpeg SC23-05.jpeg SC23-09.jpeg] },
    { title: "Setup", meta: "", href: nil,
      alt: "Ryan Scherbarth home server and PC setup",
      images: %w[Setup-10.jpeg Setup-01.jpg Setup-05.jpeg Setup-06.jpeg Setup-08.jpg Setup-09.jpg Setup-07.jpg] },
    { title: "Duke City Marathon", meta: "10/2023", href: "https://www.athlinks.com/event/35398/results/Event/1063165/Course/2408972/Bib/54",
      alt: "Ryan Scherbarth running Duke City Marathon 2023",
      images: ["DukeFull-01.jpeg", "DukeFull-03.jpeg",
               ["DukeFull-02.png", "Ryan Scherbarth Duke City Marathon 2023 results"]] },
    { title: "Duke City Half Marathon", meta: "10/2022", href: "https://www.athlinks.com/event/35398/results/Event/1032202/Course/2296577/Bib/1417",
      alt: "Ryan Scherbarth running Duke City Half Marathon 2022",
      images: ["DukeHalf-02.jpeg", "DukeHalf-03.jpg",
               ["DukeHalf-01.png", "Ryan Scherbarth Duke City Half Marathon 2022 results"]] }
  ].freeze

  def career_chapters
    CAREER_CHAPTERS
  end

  def home_panels
    HOME_PANELS
  end

  def archive_entries
    ARCHIVE_ENTRIES
  end

  def photo_plates
    PHOTO_PLATES
  end

  # 01 · Standing — the portrait carousel. [file, its own alt].
  PORTRAIT_FRAMES = [
    ["Profile-02.jpeg", "Ryan Scherbarth — SC23 HPC Competition"],
    ["Profile-01.jpg",  "Ryan Scherbarth — SC23 HPC Student Cluster Competition"],
    ["Profile-05.jpg",  "Ryan Scherbarth — SC23 HPC Cluster Competition"],
    ["Profile-03.jpeg", "Ryan Scherbarth — UNM Center for Advanced Reserach Computing"]
  ].freeze

  def portrait_frames
    PORTRAIT_FRAMES
  end

  # ── 05 · Plates — mosaic packing ────────────────────────────
  #
  # A plate is laid out as justified rows on a 60-column grid. Inside a row
  # every tile takes a share of the 60 proportional to its own aspect ratio,
  # so the tiles come out the same height, keep their true crop, and the row
  # finishes flush against both edges of the plate.
  #
  # Rows are cut against a rotating target width measured in aspect ratios
  # rather than in tiles — 3.1 is two large frames, 5.5 is four small ones.
  # That alternation is the whole trick: it is what makes the plate read as a
  # mosaic of unequal frames instead of a grid of thumbnails.
  #
  # Because every packed row sums to exactly MOSAIC_COLS the grid wraps
  # precisely where the packer intended and no row is ever left with a hole.
  # Three packings are computed per plate and ride on the tile as
  # --c1 / --c2 / --c3; CSS picks one per breakpoint, so the mosaic reflows
  # with no JS in the path.
  MOSAIC_COLS = 60

  # targets — the rotating row widths, in aspect ratios.
  # cap     — a row is closed rather than take a frame past this, which is
  #           what keeps a run of panoramas from collapsing into a letterbox.
  # fold    — fold a trailing lone frame back into the row above. On the two
  #           wide breakpoints a lone frame would be stretched across the
  #           whole plate; on a phone that is simply what a frame looks like.
  MOSAIC_RHYTHM = {
    c1: { targets: [1.6, 3.2],      cap: 4.0, fold: false }, # phone   — a frame, then a pair
    c2: { targets: [2.6, 4.0, 3.2], cap: 4.6, fold: true },  # tablet  — pairs and triples
    c3: { targets: [3.1, 5.5, 4.2], cap: 6.4, fold: true }   # desktop — a big pair, then dense rows
  }.freeze

  # Used only when an image is missing from the derivative manifest, which
  # would otherwise leave a tile with no height at all.
  MOSAIC_AR_FALLBACK = 1.5

  # One tile per frame: the file, the alt that frame owns, its true aspect
  # ratio, the largest derivative to hand to the viewer, its permalink id,
  # and its column span at each of the three breakpoints.
  #
  # `id` is the source basename. It is what a photo permalink names, so it
  # has to survive a deploy — which rules out both the packed index (every
  # frame added above a photograph renumbers it) and the delivered href
  # (Sprockets digests it).
  def photo_mosaic(plate)
    tiles = plate[:images].map do |img|
      file, alt = img.is_a?(Array) ? img : [img, plate[:alt]]
      clip = mosaic_clip?(file)
      ar = clip ? MOSAIC_CLIP_AR : mosaic_aspect(file)
      { file: file, alt: alt, ar: ar, clip: clip,
        id: File.basename(file, ".*"),
        poster: (mosaic_poster(file) if clip),
        pad: "#{(100.0 / ar).round(3)}%", full: viewer_src(file) }
    end

    MOSAIC_RHYTHM.each do |key, rhythm|
      mosaic_rows(tiles, rhythm).each do |row|
        mosaic_spans(row.map { |t| t[:ar] }).each_with_index { |span, i| row[i][key] = span }
      end
    end

    tiles
  end

  # What the viewer loads for one frame: the smallest rendition that still
  # covers a large screen, so a full-bleed frame is sharp without pulling an
  # 8064px original down the wire. Most of these photographs are only 1024px
  # to begin with, and for those the original is both the smallest and the
  # best answer. Public because the carousels hand the viewer frames too.
  MOSAIC_FULL_W = 1920

  def viewer_src(file)
    entry = image_derivatives(file)
    derivatives = entry && entry["derivatives"]
    return asset_path(file) if derivatives.blank?

    big = derivatives.sort_by { |width, _| width.to_i }.find { |width, _| width.to_i >= MOSAIC_FULL_W }
    asset_path(big ? big.last : file)
  end

  private

  # A frame may be a clip rather than a still. Both clips on the site are
  # 16:9 and neither has a manifest entry to measure, so that is the ratio
  # the packer gives them; the tile letterboxes rather than crops, so a
  # clip cut to anything else still comes out whole.
  MOSAIC_CLIP_EXT = %w[.mov .mp4 .webm].freeze
  MOSAIC_CLIP_AR  = 1.7778

  def mosaic_clip?(file)
    MOSAIC_CLIP_EXT.include?(File.extname(file).downcase)
  end

  # The still a clip shows before it is played. A frame lifted off the
  # video lives beside it as <name>-poster.jpg; without one the tile is
  # just a black rectangle, so the poster is what makes a clip read as a
  # photograph on the sheet. nil if the frame was never cut.
  def mosaic_poster(file)
    name = "#{File.basename(file, '.*')}-poster.jpg"
    asset_path(name) if File.exist?(Rails.root.join("app/assets/images", name))
  end

  def mosaic_aspect(file)
    entry = image_derivatives(file)
    w = entry && entry["width"].to_f
    h = entry && entry["height"].to_f
    return MOSAIC_AR_FALLBACK unless w&.positive? && h&.positive?

    (w / h).round(4)
  end

  # Walk the frames, closing a row the moment the next frame would take its
  # total further from the target than it already is.
  def mosaic_rows(tiles, rhythm)
    targets = rhythm[:targets]
    cap = rhythm[:cap]
    rows = []
    i = 0

    while i < tiles.length
      target = targets[rows.length % targets.length]
      row = [tiles[i]]
      sum = tiles[i][:ar]
      i += 1

      while i < tiles.length && sum + tiles[i][:ar] <= cap &&
            ((sum + tiles[i][:ar]) - target).abs < (sum - target).abs
        sum += tiles[i][:ar]
        row << tiles[i]
        i += 1
      end

      rows << row
    end

    rows[-2].concat(rows.pop) if rhythm[:fold] && rows.length > 1 && rows.last.length == 1
    rows
  end

  # Column shares proportional to aspect ratio, forced to total exactly
  # MOSAIC_COLS. The columns lost to flooring go to the tiles that lost most.
  def mosaic_spans(ratios)
    total = ratios.sum
    raw   = ratios.map { |ar| MOSAIC_COLS * ar / total }
    spans = raw.map { |v| [v.floor, 1].max }

    order = raw.each_with_index.sort_by { |v, i| [v.floor - v, i] }.map(&:last)
    (MOSAIC_COLS - spans.sum).times { |k| spans[order[k % order.length]] += 1 }

    spans
  end
end
