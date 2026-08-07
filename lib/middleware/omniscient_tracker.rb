# frozen_string_literal: true

# Sits at position 0 of the Rack stack — ahead of routing, ahead of Rails —
# so it sees the raw request the moment it lands on the dyno, including the
# ones that never reach a controller (404s, HEAD probes, scanners hammering
# /wp-login.php) and the ones that run no JavaScript and are therefore
# invisible to Google Analytics. That last group is the point: AI crawlers.
#
# Two outputs per request:
#   1. a JSON line on stdout, which is what a Heroku log drain can consume
#   2. a row in `hits`, which is what /metrics reads
#
# Neither may ever raise. A tracker that can 500 the site is worse than no
# tracker, so every failure path here degrades to silence.
class OmniscientTracker
  # Crawlers that train or retrieve for language models. Kept separate from
  # ordinary search bots because it is the question actually being asked.
  AI_BOTS = {
    "GPTBot" => /GPTBot/i,
    "OAI-SearchBot" => /OAI-SearchBot/i,
    "ChatGPT-User" => /ChatGPT-User/i,
    "ClaudeBot" => /ClaudeBot/i,
    "Claude-SearchBot" => /Claude-SearchBot/i,
    "Claude-User" => /Claude-User/i,
    "anthropic-ai" => /anthropic-ai/i,
    "PerplexityBot" => /PerplexityBot/i,
    "Perplexity-User" => /Perplexity-User/i,
    "Google-Extended" => /Google-Extended/i,
    "Bytespider" => /Bytespider/i,
    "CCBot" => /CCBot/i,
    "Diffbot" => /Diffbot/i,
    "Amazonbot" => /Amazonbot/i,
    "Applebot-Extended" => /Applebot-Extended/i,
    "meta-externalagent" => /meta-externalagent|FacebookBot/i,
    "cohere-ai" => /cohere-ai/i,
    "YouBot" => /YouBot/i,
    "Timpibot" => /Timpibot/i,
    "ImagesiftBot" => /ImagesiftBot/i
  }.freeze

  # Everything else that self-identifies as automated.
  OTHER_BOTS = {
    "Googlebot" => /Googlebot/i,
    "Bingbot" => /bingbot/i,
    "DuckDuckBot" => /DuckDuckBot/i,
    "Baiduspider" => /Baiduspider/i,
    "YandexBot" => /YandexBot/i,
    "Applebot" => /Applebot/i,
    "AhrefsBot" => /AhrefsBot/i,
    "SemrushBot" => /SemrushBot/i,
    "MJ12bot" => /MJ12bot/i,
    "DotBot" => /DotBot/i,
    "PetalBot" => /PetalBot/i,
    "Slackbot" => /Slackbot/i,
    "Discordbot" => /Discordbot/i,
    "Twitterbot" => /Twitterbot/i,
    "LinkedInBot" => /LinkedInBot/i,
    "TelegramBot" => /TelegramBot/i,
    "WhatsApp" => /WhatsApp/i,
    "UptimeRobot" => /UptimeRobot/i,
    "Pingdom" => /Pingdom/i,
    "curl" => /\Acurl\//i,
    "wget" => /\AWget/i,
    "python-requests" => /python-requests|aiohttp|httpx/i,
    "Go-http-client" => /Go-http-client/i,
    "Scrapy" => /Scrapy/i,
    "HeadlessChrome" => /HeadlessChrome/i
  }.freeze

  # Fingerprinting every stylesheet and font request would bury the signal
  # and burn the ring buffer on noise.
  IGNORED = %r{\A/(assets|packs|cable|favicon\.ico|apple-touch-icon)}.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if IGNORED.match?(env["PATH_INFO"].to_s)

    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    status, headers, body = @app.call(env)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round

    track(env, status, duration_ms)

    [status, headers, body]
  rescue StandardError
    # An exception from the app itself must keep propagating; only our own
    # bookkeeping is swallowed, and that happens inside #track.
    raise
  end

  private

  def track(env, status, duration_ms)
    agent = env["HTTP_USER_AGENT"].to_s
    ai_name = match_name(AI_BOTS, agent)
    bot_name = ai_name || match_name(OTHER_BOTS, agent)

    payload = {
      timestamp: Time.now.utc.iso8601(3),
      request_id: env["HTTP_X_REQUEST_ID"],
      remote_addr: env["REMOTE_ADDR"],
      forwarded_for: env["HTTP_X_FORWARDED_FOR"],
      forwarded_port: env["HTTP_X_FORWARDED_PORT"],
      protocol: env["HTTP_X_FORWARDED_PROTO"] || env["rack.url_scheme"],
      method: env["REQUEST_METHOD"],
      path: env["PATH_INFO"],
      query_string: env["QUERY_STRING"],
      user_agent: agent,
      ai_bot: !ai_name.nil?,
      bot: !bot_name.nil?,
      bot_name: bot_name,
      status: status,
      duration_ms: duration_ms,
      headers: http_headers(env)
    }

    Rails.logger.info("[OMNISCIENT_TRACKER] " + payload.to_json)

    persist(payload, agent, ai_name, bot_name)
  rescue StandardError => e
    Rails.logger.warn("[OMNISCIENT_TRACKER] failed: #{e.class}: #{e.message}")
  end

  # Every HTTP_* key Rack collected: Accept, Referer, Sec-Fetch-*, cache
  # controls, client hints, and whatever else the client volunteered.
  def http_headers(env)
    env.each_with_object({}) do |(key, value), out|
      next unless key.is_a?(String) && key.start_with?("HTTP_")
      next unless value.is_a?(String)

      out[key.sub("HTTP_", "").downcase.tr("_", "-")] = value.byteslice(0, 512)
    end
  end

  def match_name(table, agent)
    return nil if agent.empty?

    table.each { |name, pattern| return name if pattern.match?(agent) }
    nil
  end

  def persist(payload, agent, ai_name, bot_name)
    return unless defined?(Hit) && ActiveRecord::Base.connected?

    device = DeviceDetectorShim.for(agent)

    Hit.record!(
      occurred_at: Time.now.utc,
      request_id: payload[:request_id],
      method_verb: payload[:method],
      path: payload[:path].to_s[0, 512],
      query_string: payload[:query_string].to_s[0, 512],
      protocol: payload[:protocol],
      ip: payload[:remote_addr],
      forwarded_for: payload[:forwarded_for],
      forwarded_port: payload[:forwarded_port],
      user_agent: agent[0, 1024],
      referer: payload[:headers]["referer"],
      bot_name: bot_name,
      ai_bot: !ai_name.nil?,
      bot: !bot_name.nil?,
      device_type: device[:device],
      browser: device[:browser],
      os: device[:os],
      status: payload[:status],
      duration_ms: payload[:duration_ms],
      headers: payload[:headers].to_json
    )
  end

  # device_detector is optional; if it is not installed the columns simply
  # stay blank rather than the tracker exploding.
  module DeviceDetectorShim
    def self.for(agent)
      return {} if agent.blank?
      return {} unless defined?(DeviceDetector)

      d = DeviceDetector.new(agent)
      { device: d.device_type, browser: d.name, os: d.os_name }
    rescue StandardError
      {}
    end
  end
end
