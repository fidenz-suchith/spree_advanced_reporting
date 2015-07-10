Spree::Admin::ReportsController.class_eval do
  before_filter :add_own 
  before_filter :basic_report_setup, :actions => [:profit, :revenue, :units, :top_products, :top_customers, :geo_revenue, :geo_units, :count]

  def add_own
    #return if Spree::Admin::ReportsController::AVAILABLE_REPORTS.has_key?(:geo_profit)
    Spree::Admin::ReportsController.available_reports.merge!(ADVANCED_REPORTS)
  end
  I18n.locale = Rails.application.config.i18n.default_locale
  I18n.reload!

  ADVANCED_REPORTS ||= {}
  [ :revenue, :units, :profit, :count, :top_products, :top_customers, :geo_revenue, :geo_units, :geo_profit].each do |x|
    ADVANCED_REPORTS[x]= {name: I18n.t("adv_report."+x.to_s), :description => I18n.t("adv_report."+x.to_s)}
  end

   
  def basic_report_setup
    @reports = ADVANCED_REPORTS
    @products = Spree::Product.all
    @taxons = Spree::Taxon.all
    if defined?(MultiDomainExtension)
      @stores = Store.all
    end
  end

  def geo_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]["report_type"] = params[:advanced_reporting]["report_type"].to_sym if params[:advanced_reporting]["report_type"]
    params[:advanced_reporting]["report_type"] ||= :state
    respond_to do |format|
      format.html { render :template => "spree/admin/reports/geo_base" }
      # format.pdf do
      #   send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_pdf
      # end
      format.csv do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv
      end
    end
  end

  def base_report_top_render(filename)
    respond_to do |format|
      format.html { render :template => "spree/admin/reports/top_base" }
      # format.pdf do
      #   send_data @report.ruportdata.to_pdf
      # end
      format.csv do
        send_data @report.ruportdata.to_csv
      end
    end
  end

  def base_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]["report_type"] = params[:advanced_reporting]["report_type"].to_sym if params[:advanced_reporting]["report_type"]
    params[:advanced_reporting]["report_type"] ||= :daily
    respond_to do |format|
      format.html { render :template => "spree/admin/reports/increment_base" }
      # format.pdf do
      #   if params[:advanced_reporting]["report_type"] == :all
      #     send_data @report.all_data.to_pdf
      #   else
      #     send_data @report.ruportdata[params[:advanced_reporting]["report_type"]].to_pdf
      #   end
      # end
      format.csv do
        if params[:advanced_reporting]["report_type"] == :all
          send_data @report.all_data.to_csv
        else
          send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv
        end
      end
    end
  end

  def revenue
    @report = Spree::AdvancedReport::IncrementReport::Revenue.new(params)
    base_report_render("revenue")
  end

  def units
    @report = Spree::AdvancedReport::IncrementReport::Units.new(params)
    base_report_render("units")
  end

  def profit
    @report = Spree::AdvancedReport::IncrementReport::Profit.new(params)
    base_report_render("profit")
  end

  def count
    @report = Spree::AdvancedReport::IncrementReport::Count.new(params)
    base_report_render("profit")
  end

  def top_products
    @report = Spree::AdvancedReport::TopReport::TopProducts.new(params, 4)
    base_report_top_render("top_products")
  end

  def top_customers
    @report = Spree::AdvancedReport::TopReport::TopCustomers.new(params, 4)
    base_report_top_render("top_customers")
  end

  def geo_revenue
    @report = Spree::AdvancedReport::GeoReport::GeoRevenue.new(params)
    geo_report_render("geo_revenue")
  end

  def geo_units
    @report = Spree::AdvancedReport::GeoReport::GeoUnits.new(params)
    geo_report_render("geo_units")
  end

  def geo_profit
    @report = Spree::AdvancedReport::GeoReport::GeoProfit.new(params)
    geo_report_render("geo_profit")
  end
end
