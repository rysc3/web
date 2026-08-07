class CreateTrackingTables < ActiveRecord::Migration[6.1]
  def change
    # ── Raw requests: a fixed-size ring buffer ──────────────────────────
    #
    # Every request that reaches the dyno lands here. The table is capped
    # (see Hit::MAX_ROWS) and the oldest rows are pruned, so it occupies a
    # bounded amount of disk forever rather than growing until the database
    # falls over. Detail is disposable; the rollup below is what survives.
    create_table :hits do |t|
      t.datetime :occurred_at, null: false
      t.string   :request_id            # Heroku's HTTP_X_REQUEST_ID
      t.string   :method_verb, limit: 10
      t.string   :path
      t.string   :query_string
      t.string   :protocol, limit: 16
      t.string   :ip
      t.string   :forwarded_for
      t.string   :forwarded_port, limit: 10
      t.string   :user_agent, limit: 1024
      t.string   :referer
      t.string   :bot_name               # nil when it does not look like a bot
      t.boolean  :ai_bot, null: false, default: false
      t.boolean  :bot,    null: false, default: false
      t.string   :device_type, limit: 32
      t.string   :browser, limit: 64
      t.string   :os, limit: 64
      t.integer  :status
      t.integer  :duration_ms
      t.text     :headers                # every HTTP_* key, as JSON

      t.index :occurred_at
      t.index :ai_bot
      t.index :bot_name
      t.index :path
    end

    # ── Daily rollups: permanent, tiny ─────────────────────────────────
    #
    # One row per day per bucket. Survives pruning, so "traffic over time"
    # keeps working long after the raw rows for that day are gone. A year
    # of heavy traffic is still only a few thousand rows.
    create_table :hit_rollups do |t|
      t.date   :day, null: false
      t.string :bucket, null: false      # "total" | "path" | "bot" | "ai_bot" | "status" | "device"
      t.string :key, null: false         # the value inside that bucket
      t.bigint :count, null: false, default: 0

      t.index %i[day bucket key], unique: true, name: "index_hit_rollups_on_day_bucket_key"
      t.index :day
    end
  end
end
