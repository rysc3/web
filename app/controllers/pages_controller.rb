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
    @og_image = "tesla-battery.jpg"
    @page_title = "Ryan's sentry graph"
  end

  def stock
    @og_image = "stock.jpg"
    @page_title = "Ryan's Epic Stock Calculator"

    @current_price = fetch_price
    @end = params[:end].present? ? params[:end].to_f : @current_price
    @start = params[:start].present? ? params[:start].to_f : 308.0
    @opt_pct = (params[:opt_pct].presence || 0).to_f / 100.0
    @pkg_value = params[:package].to_f

    if @start.positive? && @end.positive?
      delta_pct = (@end - @start) / @start

      option_gain = delta_pct * 3 * @opt_pct
      rsu_gain = delta_pct * (1 - @opt_pct)
      total_gain_pct = option_gain + rsu_gain

      @gain_pct = (total_gain_pct * 100).round(1)

      if @pkg_value.positive?
        @total_gain = (@pkg_value * total_gain_pct).round(2)
      end

      @break_even = @start
    end
  end


  private

  def fetch_price
    uri = URI("https://query1.finance.yahoo.com/v8/finance/chart/TSLA?range=1d&interval=1d")
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    data = JSON.parse(response.body)
    data.dig("chart", "result", 0, "meta", "regularMarketPrice") || 0
  rescue => e
    Rails.logger.error("Failed to fetch price: #{e.message}")
    0
  end

end
