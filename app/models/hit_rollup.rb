# Permanent daily counters.
#
# Hit is a ring buffer — its rows are deleted once the cap is reached, so it
# cannot answer "how did traffic change over the last two years". This can:
# one row per day per bucket per key, incremented as requests arrive, never
# pruned. Even a heavily crawled year is a few thousand rows.
class HitRollup < ApplicationRecord
  BUCKETS = %w[total agent path status device].freeze

  scope :for_bucket, ->(bucket) { where(bucket: bucket) }
  scope :since, ->(date) { where(day: date..) }

  # Fold one request into the day's counters.
  def self.absorb(hit)
    day = hit.occurred_at.to_date

    tally(day, "total", "all")
    tally(day, "total", hit.ai_bot? ? "ai_bot" : (hit.bot? ? "bot" : "human"))
    tally(day, "agent", hit.label)
    tally(day, "path", hit.path.to_s[0, 120])
    tally(day, "status", hit.status.to_s) if hit.status
    tally(day, "device", hit.device_type) if hit.device_type.present?
  rescue StandardError => e
    # A counter must never take a page down.
    Rails.logger.warn("[HitRollup] #{e.class}: #{e.message}")
  end

  # An atomic upsert-and-increment. Two dynos can race on the same row, so
  # the unique index is the arbiter: on conflict we fall through to an
  # in-place increment rather than trusting a read-then-write.
  def self.tally(day, bucket, key, by = 1)
    key = key.to_s.presence || "unknown"

    updated = where(day: day, bucket: bucket, key: key).update_all("count = count + #{by.to_i}")
    return if updated.positive?

    create!(day: day, bucket: bucket, key: key, count: by)
  rescue ActiveRecord::RecordNotUnique
    where(day: day, bucket: bucket, key: key).update_all("count = count + #{by.to_i}")
  end
end
