class Ahoy::Store < Ahoy::DatabaseStore
end

# ── Bots are the point ──────────────────────────────────────────────────
#
# Ahoy discards bot traffic by default, which is exactly backwards here:
# the crawlers that never run JavaScript — and therefore never appear in
# Google Analytics — are the traffic this site most wants to see.
Ahoy.track_bots = true

# Correlate a visit with the raw request row written by OmniscientTracker.
Ahoy.server_side_visits = :when_needed

# A visit is a session, not a lifetime. Long enough to group a crawl,
# short enough that the tables stay small.
Ahoy.visit_duration = 4.hours
Ahoy.visitor_duration = 2.years

# Heroku terminates TLS at the router, so the real client address is in
# X-Forwarded-For rather than REMOTE_ADDR.
Ahoy.mask_ips = false

# Geocoding needs a paid lookup service; leave it off rather than pretend.
Ahoy.geocode = false
