# One raw request that reached the dyno.
#
# This table is a RING BUFFER, not an archive. It is capped at MAX_ROWS and
# the oldest rows are deleted past that, so the database occupies a bounded
# amount of space no matter how long the site runs or how hard it is
# crawled. Long-term history lives in HitRollup, which is permanent and
# tiny.
class Hit < ApplicationRecord
  # Sized for Heroku's smallest Postgres plan (1 GB). A row averages well
  # under 2 KB even with the full header dump, so 100k rows is roughly
  # 150–200 MB — a comfortable fraction of the plan, with room for Ahoy's
  # tables and the rollups beside it. Override with TRACKER_MAX_HITS.
  MAX_ROWS = Integer(ENV.fetch("TRACKER_MAX_HITS", 100_000))

  # Pruning scans and deletes, so it must not run on every request. At 1 in
  # 250 the buffer overshoots its cap by a few hundred rows at worst.
  PRUNE_ODDS = 250

  # Delete in one bite rather than trickling, so the scan cost is amortised
  # over many thousands of subsequent requests.
  PRUNE_SLACK = 2_000

  scope :recent, -> { order(occurred_at: :desc) }
  scope :ai, -> { where(ai_bot: true) }
  scope :humans, -> { where(bot: false) }
  scope :since, ->(time) { where(occurred_at: time..) }

  def self.record!(attrs)
    hit = create!(attrs)
    HitRollup.absorb(hit)
    prune! if rand(PRUNE_ODDS).zero?
    hit
  end

  # Trim back to the cap. Uses a single id threshold rather than an
  # OFFSET/LIMIT delete, which SQLite cannot express and Postgres would
  # execute as a sort over the whole table.
  def self.prune!
    excess = count - MAX_ROWS
    return 0 if excess < PRUNE_SLACK

    cutoff = order(id: :asc).offset(excess).limit(1).pick(:id)
    return 0 unless cutoff

    where(id: ...cutoff).delete_all
  end

  def headers_hash
    return {} if headers.blank?

    JSON.parse(headers)
  rescue JSON::ParserError
    {}
  end

  def label
    bot_name.presence || browser.presence || "unknown"
  end
end
