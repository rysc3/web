# When this site last changed.
#
# Two sources, in order of preference:
#   1. the local git checkout — free, instant, and exact
#   2. the GitHub API for the public repo's default branch, for hosts that
#      deploy without a .git directory (this one does; see .slugignore)
#
# The answer is memoised in-process with a TTL, and a failure is memoised
# too. A footer stamp must never make a page wait on api.github.com, and
# must never take the page down if GitHub is unreachable — on any error
# this returns nil and the stamp simply does not render.
module SiteStatusHelper
  REPO = "rysc3/web".freeze
  TTL = 1.hour
  API_TIMEOUT = 2 # seconds

  class << self
    attr_accessor :cached_at, :cached_value
  end

  def last_updated_at
    if SiteStatusHelper.cached_at && SiteStatusHelper.cached_at > Time.current - TTL
      return SiteStatusHelper.cached_value
    end

    value = git_last_commit_at || github_last_commit_at
    SiteStatusHelper.cached_at = Time.current
    SiteStatusHelper.cached_value = value
    value
  end

  # The absolute date. The elapsed part is rendered client-side so it can
  # be cycled through units on click.
  def last_updated_date
    at = last_updated_at
    at && at.strftime("%b %-d, %Y")
  end

  # Milliseconds since the last change, fixed at render time. The footer
  # counts down from this rather than from a live clock, so every unit it
  # shows agrees with every other one.
  def last_updated_elapsed_ms
    at = last_updated_at
    at && ((Time.current - at) * 1000).round
  end

  private

  def git_last_commit_at
    root = Rails.root.join(".git")
    return nil unless File.exist?(root)

    out = `git -C #{Rails.root} log -1 --format=%cI 2>/dev/null`.strip
    return nil if out.empty?

    Time.iso8601(out)
  rescue StandardError
    nil
  end

  def github_last_commit_at
    uri = URI("https://api.github.com/repos/#{REPO}/commits?per_page=1")

    body = Net::HTTP.start(uri.host, uri.port,
                           use_ssl: true,
                           open_timeout: API_TIMEOUT,
                           read_timeout: API_TIMEOUT) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["User-Agent"] = "ryanscherbarth.com"
      response = http.request(request)
      return nil unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    stamp = JSON.parse(body).dig(0, "commit", "committer", "date")
    stamp && Time.iso8601(stamp)
  rescue StandardError
    nil
  end
end
