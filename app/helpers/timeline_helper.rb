# Geometry for 02 · Trajectory.
#
# The career record carries a human date string and, alongside it, a
# machine reading of the same dates. Here those become indices on one
# linear month axis — drawn with the present at the top, so reading
# downwards walks backwards — and then get packed into lanes by a sweep,
# so anything that ran at the same time stands shoulder to shoulder
# instead of on top of itself.
#
# Nothing in here is allowed to change a displayed date — `dates` is
# rendered verbatim by the view. These numbers only drive bar geometry.
module TimelineHelper
  # Month indices count from January of this year, so index arithmetic
  # is plain integers rather than Date maths.
  TL_EPOCH = 2000

  # Months of empty axis kept beyond either end of the record: a little
  # air past the earliest start, and enough past today that open-ended
  # roles have somewhere to run out to.
  TL_HEAD = 1
  TL_TAIL = 5

  def career_timeline
    @career_timeline ||= build_career_timeline
  end

  # "2024-07" → absolute month index.
  def tl_month_index(str)
    year, month = str.to_s.split("-").map(&:to_i)
    (year - TL_EPOCH) * 12 + (month - 1)
  end

  # The measured voice: "2 yr 5 mo".
  def tl_duration_short(months)
    years, rest = months.divmod(12)
    return "#{rest} mo" if years.zero?
    return "#{years} yr" if rest.zero?
    "#{years} yr #{rest} mo"
  end

  # The spoken voice: "2 years 5 months".
  def tl_duration_long(months)
    years, rest = months.divmod(12)
    parts = []
    parts << "#{years} #{'year'.pluralize(years)}" if years.positive?
    parts << "#{rest} #{'month'.pluralize(rest)}" if rest.positive?
    parts.join(" ")
  end

  private

  def build_career_timeline
    today = Date.today
    now = (today.year - TL_EPOCH) * 12 + (today.month - 1)

    # Roles sharing a `tenure` collapse into one run: one bar, one entry,
    # with the promotions marked inside it. Everything else is its own row.
    groups = []
    by_tenure = {}

    career_chapters.flat_map { |c| c[:entries] }.each do |entry|
      key = entry[:tenure]
      if key && by_tenure[key]
        by_tenure[key][:roles] << entry
        next
      end
      group = { entry: entry, roles: [entry] }
      by_tenure[key] = group if key
      groups << group
    end

    rows = groups.each_with_index.map do |group, i|
      roles = group[:roles]

      first = roles.map { |e| tl_month_index(e[:start]) }.min
      ends  = roles.map { |e| e[:end] && tl_month_index(e[:end]) }
      open  = ends.any?(&:nil?)
      final = open ? nil : ends.compact.max
      final = first if final && final < first
      last  = open ? [now, first].max : final

      # Composed from the outermost roles' own words — never invented.
      dates =
        if roles.size > 1
          "#{roles.last[:dates].split(/\s+—\s+/).first} — #{roles.first[:dates].split(/\s+—\s+/).last}"
        else
          group[:entry][:dates]
        end

      # Where each promotion lands, in months from the start of the run.
      promos = roles[0..-2].map { |role| tl_month_index(role[:start]) - first }
                           .reject { |k| k <= 0 }

      { entry: group[:entry], roles: roles, dates: dates, promos: promos,
        first: first, last: last, open: open,
        months: last - first + 1, order: i }
    end

    t0 = rows.map { |r| r[:first] }.min - TL_HEAD
    t1 = [rows.map { |r| r[:last] }.max, now].max + TL_TAIL
    span = t1 - t0

    # The axis runs newest at the top, so every position is measured
    # DOWN from the present. `top` is the display coordinate of a run's
    # end; `t` stays the forward month offset of its start, which is
    # what the record and the playhead reason about.
    rows.each do |r|
      r[:t] = r[:first] - t0
      r[:d] = r[:open] ? t1 - r[:first] : r[:months]
      r[:top] = span - (r[:t] + r[:d])
      r[:reach] = r[:open] ? t1 : r[:last]
      r[:dur_short] = tl_duration_short(r[:months])
      r[:dur_long] =
        if r[:open]
          "Ongoing, #{tl_duration_long(r[:months])} so far."
        else
          "Duration: #{tl_duration_long(r[:months])}."
        end
    end

    # ── Interval packing ──────────────────────────────────────
    # A standard sweep, run down the axis as it is drawn: take the runs
    # in the order their bars begin (newest end first) and drop each one
    # into the leftmost lane whose current occupant has already started
    # — i.e. finished, reading downwards into the past. Otherwise open a
    # new lane. Longer runs go first so they take the inner lanes and
    # the chart reads as a delta rather than a scatter.
    sweep = rows.sort_by do |r|
      [-r[:reach], -r[:months], r[:entry][:track] == "professional" ? 0 : 1, r[:order]]
    end

    lane_floor = []
    sweep.each do |r|
      lane = lane_floor.index { |begun| begun > r[:reach] } || lane_floor.size
      lane_floor[lane] = r[:first]
      r[:lane] = lane
    end

    # Reading order: newest first, matching the axis.
    rows.sort_by! do |r|
      [-r[:first], -r[:months], r[:entry][:track] == "professional" ? 0 : 1, r[:order]]
    end

    years = ((t0 / 12)..(t1 / 12)).map { |k| { year: TL_EPOCH + k, t: span - (k * 12 - t0) } }
    years.select! { |y| y[:t] > 1 && y[:t] < span - 1 }

    { rows: rows,
      span: span,
      lanes: lane_floor.size,
      months: (0..span).map { |t| { t: span - t, major: ((t + t0) % 12).zero? } },
      years: years,
      now_t: span - (now - t0),
      peak: tl_peak_concurrency(rows),
      y0: TL_EPOCH + t0 / 12,
      m0: (t0 % 12) + 1,
      from: TL_EPOCH + t0 / 12,
      to: today.year }
  end

  # The most engagements ever running in one month — the headline number
  # for a chart whose whole subject is overlap.
  def tl_peak_concurrency(rows)
    counts = Hash.new(0)
    rows.each { |r| (r[:first]..r[:last]).each { |m| counts[m] += 1 } }
    counts.values.max || 0
  end
end
