# The hidden dashboard. Nothing links to it — it exists at /metrics and
# nowhere else, deliberately.
#
# Every query here is bounded: the ring buffer is capped at Hit::MAX_ROWS,
# and each aggregate takes a LIMIT. Nothing on this page can degrade as the
# table fills, because the table cannot grow past its cap.
class MetricsController < ApplicationController
  layout "application"

  WINDOWS = { "1h" => 1.hour, "24h" => 24.hours, "7d" => 7.days, "30d" => 30.days, "all" => nil }.freeze
  FEED_LIMIT = 120
  TOP_LIMIT = 12

  def index
    @page_title = "Metrics"
    @og_description = "Request telemetry."
    @window_key = WINDOWS.key?(params[:w]) ? params[:w] : "7d"
    span = WINDOWS[@window_key]
    scope = span ? Hit.since(span.ago) : Hit.all

    @total = scope.count
    @ai = scope.ai.count
    @bots = scope.where(bot: true).count
    @humans = @total - @bots
    @unique_ips = scope.distinct.count(:ip)
    @avg_ms = scope.average(:duration_ms)&.round

    @all_agents = top(scope, :bot_name)
    @paths = top(scope, :path)
    @statuses = top(scope, :status)
    @browsers = top(scope, :browser)
    @devices = top(scope, :device_type)
    @referers = top(scope.where.not(referer: [nil, ""]), :referer)

    @by_hour = scope.group("strftime('%H', occurred_at)").count if sqlite?
    @by_hour ||= scope.group("EXTRACT(HOUR FROM occurred_at)").count

    @feed = scope.recent.limit(FEED_LIMIT)
    @buffer_used = Hit.count
    @buffer_cap = Hit::MAX_ROWS
    @rollup_days = HitRollup.distinct.count(:day)
  end

  def show
    @page_title = "Request"
    @hit = Hit.find(params[:id])

    # Built here rather than in the template: HAML cannot parse a
    # multi-line Ruby hash literal.
    @fields = {
      "When" => @hit.occurred_at&.utc&.iso8601(3),
      "Request ID" => @hit.request_id,
      "Status" => @hit.status,
      "Duration" => (@hit.duration_ms && "#{@hit.duration_ms} ms"),
      "Protocol" => @hit.protocol,
      "Query" => @hit.query_string.presence,
      "Remote addr" => @hit.ip,
      "X-Forwarded-For" => @hit.forwarded_for,
      "X-Forwarded-Port" => @hit.forwarded_port,
      "Referer" => @hit.referer,
      "Bot" => @hit.bot_name,
      "AI crawler" => (@hit.ai_bot? ? "yes" : "no"),
      "Browser" => @hit.browser,
      "OS" => @hit.os,
      "Device" => @hit.device_type
    }.reject { |_, v| v.blank? }
  end

  private

  def sqlite?
    ActiveRecord::Base.connection.adapter_name.downcase.include?("sqlite")
  end

  # `status` is an integer column, and comparing it against "" makes
  # SQLite coerce the whole predicate to false — which silently emptied the
  # status breakdown. Only strings get the blank guard.
  def top(scope, column)
    blanks = scope.columns_hash[column.to_s]&.type == :string ? [nil, ""] : [nil]

    scope.where.not(column => blanks)
         .group(column)
         .order(Arel.sql("COUNT(*) DESC"))
         .limit(TOP_LIMIT)
         .count
  end
end
