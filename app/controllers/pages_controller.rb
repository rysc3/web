class PagesController < ApplicationController
  require 'net/http'
  require 'json'
  require 'uri'
  layout "application"

  def index
    # logic for index

    raw_referrals = [
      { title: "Amex Platinum", url: "https://americanexpress.com/en-us/referral/all-cards?ref=RYANS49Yg&xl=cp01" },
      { title: "Amex Gold", url: "https://americanexpress.com/en-us/referral/all-cards?ref=RYANS49Yg&xl=cp01" },
      { title: "Amex Blue Business Plus", url: "https://americanexpress.com/en-us/referral/bluebusinessplus-credit-card?ref=RYANSHIde&xl=cp01" },
      { title: "Amex Amazon Business Prime", url: "https://americanexpress.com/en-us/referral/cobrand/RYANSgM2B?xl=cp01" },
      { title: "Rakuten", url: "https://www.rakuten.com/r/RYSCHE6?eeid=28187" },
      { title: "Tesla", url: "https://ts.la/ryan389904" },
      { title: "Discover IT chrome", url: "https://refer.discover.com/s/mppdhv" },
      { title: "Charles Schwab", url: "https://www.schwab.com/client-referral?refrid=REFERAEFCQQHP" },
      { title: "Robinhood", url: "https://join.robinhood.com/ryans-b88a99c8" },
      { title: "Chase Checking", url: "https://accounts.chase.com/raf/share/3038128043" },
      { title: "Chase Freedom Unlimited", url: "https://www.referyourchasecard.com/18M/ZZLNKA0Z3V" },
      # { title: "Capital One", url: "https://i.capitalone.com/GnbszHlhH" },
      { title: "Monarch", url: "https://www.monarchmoney.com/referral/jaegm89sj1" },
      { title: "Lemonade", url: "https://lemonade.com/r/ryanscherbarth" }
    ]

    @referrals = raw_referrals.group_by { |ref| ref[:title][0].upcase }
                                .sort
                                .flat_map { |letter, refs| refs.sort_by { |ref| ref[:title].length } }
  end

  def show
  end

  def sc26
    @og_image       = "SC26-01.png"
    @page_title     = "SC26 — Team UNM"
    @og_description = "SC26 HPC Student Cluster Competition — Team UNM."
  end

  def sc24
    @og_image       = "SC24-33.jpeg"
    @page_title     = "Ryan @ SC24"
    @og_description = "SC24 HPC Student Cluster Competition — Team UNM, Atlanta 2024."
  end

  def sc23
    @og_image       = "SC23-06.jpeg"
    @page_title     = "Ryan @ SC23"
    @og_description = "SC23 HPC Student Cluster Competition — Team UNM, Denver 2023."
  end

  def resume
    @og_image       = "Profile-01.jpg"
    @page_title     = "Ryan Scherbarth — Resume"
    @og_description = "Resume and experience — Sr. Software Engineer, ML & HPC Infra at Tesla."
  end

  def meet
    @og_image       = "SC24-14.jpeg"
    @page_title     = "Meet with Ryan"
    @og_description = "Schedule a meeting with Ryan Scherbarth."
  end

  def courses
    @og_image       = "Profile-03.jpeg"
    @page_title     = "Ryan Scherbarth — Courses"
    @og_description = "Course history — B.S. Computer Science, University of New Mexico, Dec 2024."
  end

  def web
    @page_title = "Ryan's Site Info"
  end

  def tesla_battery
    @og_image = "tesla-battery.png"
    @page_title = "Ryan's sentry graph"
  end

  def sitemap
    render layout: false
  end

  def not_found
    @og_image   = "Profile-05.jpg"
    @page_title = "404 — Ryan Scherbarth"
    render status: 404
  end

end
