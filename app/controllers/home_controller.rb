class HomeController < ApplicationController
  before_filter :check_login, :only => [:notifications, :analytics, :daily_report]

  def index
    flash.discard
    if logged_in?
      if current_user.profile.nil?
        render :template => "users/profile"
      elsif current_user.products.size <= 0
        render :template => "products/product_catalog"
      else
        @notifications = [["profile", current_user.profile.created_at], ["prices", current_user.products.last.created_at]]
        @notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
        render :template => "/home/notifications"
      end
#    else
#      render :template => "users/biz"
    end
  end

  def notifications
    @notifications = [["profile", current_user.profile.created_at], ["prices", current_user.products.last.created_at]]
    @notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
#    Notification.deliver_sendcoupon("abstartup@gmail.com")
  end

  def analytics
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @size = 6
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @titleX = "Time Period"
    @titleY = "#"
    @colors = []
    @i = 0

    case @page
      when @i+=1
        @title = "% said= (Yes, No)"
        @titleY = "%"
        @titleX = "response"
        @offer_yes = Offer.count(:conditions => "response LIKE 'accepted' OR response LIKE 'paid'")
        @offer_no = Offer.count(:conditions => "response LIKE 'rejected'")
        total = ((@offer_yes.to_i+@offer_no.to_i) > 0) ? (@offer_yes.to_i+@offer_no.to_i) : 1
        @chart_data1 = [["Yes", (@offer_yes.to_i*100/total)], ["No", (@offer_no.to_i*100/total)]]
      when @i+=1
        @title = "% Of Yes Hit Get Coupon"
        @titleY = "%"
        @titleX = "response"
        @offer_yes = Offer.count(:conditions => "response LIKE 'accepted'")
        @offer_paid = Offer.count(:conditions => "response LIKE 'paid'")
        total = ((@offer_yes.to_i+@offer_paid.to_i) > 0) ? (@offer_yes.to_i+@offer_paid.to_i) : 1
        @chart_data1 = [["coupon", (@offer_paid.to_i*100/total)]]
      when @i+=1
        @title = "# of coupons by day"
        @titleY = "#"
        @titleX = "date"
        @payments = Payment.all(:select => "COUNT(id) as total, Date(created_at) as date", :group => "Date(created_at)")
        @chart_data1 = []
        for payment in @payments
          @chart_data1 << [payment.date.to_date.strftime("%b %d"), payment.total.to_i]
        end
      when @i+=1
        @title = "# Came to SYP Capsule"
        @offer_today = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today}'")
        @offer_yesterday = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
      when @i+=1
        @title = "# Started Negotiating"
        @offer_today = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today}'")
        @offer_yesterday = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
      when @i+=1
        @title = "# Reached Pricing Agreement"
        @offer_today = Offer.first(:select => "SUM(counter) as total", :conditions => "offers.response='paid' and Date(offers.updated_at)='#{Date.today}'")
        @offer_yesterday = Offer.first(:select => "SUM(counter) as total", :conditions => "offers.response='paid' and Date(offers.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
      when @i+=1
        @title = "# Completed Sale"
        @offer_today = Payment.first(:select => "COUNT(id) as total", :conditions => "Date(payments.updated_at)='#{Date.today}'")
        @offer_yesterday = Payment.first(:select => "COUNT(id) as total", :conditions => "Date(payments.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
      when @i+=1
        @title = "$ Completed Sales"
        @titleY = "$"
        @offer_today = Payment.first(:select => "SUM(price) as total", :conditions => "Date(payments.updated_at)='#{Date.today}'")
        @offer_yesterday = Payment.first(:select => "SUM(price) as total", :conditions => "Date(payments.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
      else
        @title = "# Came to SYP Capsule"
        @offer_today = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today}'")
        @offer_yesterday = Offer.first(:select => "SUM(counter) as total", :conditions => "Date(offers.updated_at)='#{Date.today - 1.day}'")
        @chart_data1 = [["Yesterday", @offer_yesterday.total.to_i], ["Today", @offer_today.total.to_i]]
    end
  end

  def say_your_price
    if logged_in?
      redirect_to root_path
      return
    end
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @size = Product.count.to_i
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @products = Product.all(:limit => "#{@per_page*(@page - 1)}, #{@per_page}")

    @page_start_num = ((@page - 4) > 0) ? (@page - 4) : 1
    @page_end_num = ((@page_start_num + 8) > @post_pages) ? @post_pages : (@page_start_num + 8)
    @page_start_num = ((@post_pages - @page_end_num) < 8) ? (@page_end_num - 8) : @page_start_num
  end

  def winners
    @payments = Payment.all(:order => "id desc", :limit => 100)
  end

	def send_daily_report
#    recipients = "abstartup@gmail.com, dhaval.parikh33@gmail.com"
    recipients = "mailtoankitparekh@gmail.com, dhaval.parikh33@gmail.com"
    @today = Date.today-1.day
    @todays_coupons = Offer.all(:select => "COUNT(id) as total, price", :conditions => ["Date(updated_at) = ? and response LIKE 'paid'", @today], :group => "price")
    @all_coupons = Offer.all(:select => "COUNT(id) as total, price", :conditions => ["response LIKE 'paid'"], :group => "price")

    @analytics_overall = analytics_details('2011-03-02', @today)
    @analytics_today = analytics_details(@today, @today)

    Notification.deliver_dailyreport(recipients,@todays_coupons,@all_coupons,@analytics_today,@analytics_overall,@today)
    flash[:notice] = "Report Sent"
    redirect_to root_path
  end

	def daily_report
    @today = Date.today-1.day
    @todays_coupons = Offer.all(:select => "COUNT(id) as total, price", :conditions => ["Date(updated_at) = ? and response LIKE 'paid'", @today], :group => "price")
    @all_coupons = Offer.all(:select => "COUNT(id) as total, price", :conditions => ["response LIKE 'paid'"], :group => "price")

    @analytics_overall = analytics_details('2011-03-02', @today)
    @analytics_today = analytics_details(@today, @today)
    render :layout => false
  end
end
