class PagesController < ApplicationController
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

  def sc24
    @og_image = "SC24-27.jpg"
    @page_title = "Ryan @ SC24"
  end

  def sc23
    @og_image = "SC23-06.jpeg"
    @page_title = "Ryan @ SC23"
  end

  def resume
    @page_title = "Ryan's Resume"
  end

  def web
    @page_title = "Ryan's Site Info"
  end

  def tesla_battery
    @og_image = "tesla-battery.png"
    @page_title = "Ryan's sentry graph"
  end

  def stock
    @start     = params[:start].to_f
    @end       = params[:end].to_f
    @opt_pct   = params[:opt_pct].to_f / 100.0
    @pkg_value = params[:package].to_f

    if @start.positive? && @end.positive?
      rsu_pct = 1.0 - @opt_pct
      delta = [@end - @start, 0].max

      initial_value = @start
      current_value = rsu_pct * @end + @opt_pct * 3 * delta
      @gain_pct = ((current_value - initial_value) / initial_value * 100).round(1)

      @new_pkg_value = @pkg_value.positive? ? (@pkg_value * current_value / initial_value) : nil
    end
  end

end
