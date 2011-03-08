class ProductsController < ApplicationController
  before_filter :check_login, :except => [:capsule, :download_pdf, :send_to, :payments, :success, :cancel]

  def product_catalog
    @products = current_user.products
    if request.post?
      if !params[:uploaded_file].blank?
        file = params[:uploaded_file]
        FileUtils.mkdir_p "#{RAILS_ROOT}/public/uploads"

        file_path = "#{RAILS_ROOT}/public/uploads/#{Time.now.to_date}_#{file.original_filename}"
        if file_path.match(/(.*?)[.](.*?)/)
          mime_extension = File.mime_type?(file_path)
        else
            flash[:error]="Hey, files in csv format please"
            return
        end

        if mime_extension.eql? "text/csv" or mime_extension.eql? "text/comma-separated-values"
            if !file.local_path.nil?
               FileUtils.copy_file(file.local_path,"#{file_path}")
            else
               File.open("#{file_path}", "wb") { |f| f.write(file.read) }
            end

            @file=File.open(file_path)
            n=0
            CSV::Reader.parse(File.open("#{file_path}", 'rb')) do |row|
                product = Product.new
                product.user = current_user
                if row.size == 8
                    if row[0]
                      product.style_num = row[0].strip.gsub(/\D+/, '')
                      product.style_description = row[1].to_s
                      product.color_description = row[2].to_s
                      product.first_cost = row[3].gsub(/[^0-9\.]/, '').to_f if row[3]
                      product.ticketed_retail = row[4].gsub(/[^0-9\.]/, '').to_f if row[4]
                      product.margin = row[5].gsub(/[^0-9\.]/, '').to_f if row[5]
                      product.margin_price = row[6].gsub(/[^0-9\.]/, '').to_f if row[6]
                      product.selling_price = row[7].gsub(/[^0-9\.]/, '').to_f if row[7]
                    end
                    product.errors.add_to_base("Hey, regular price must be atleast 1") if product.first_cost.to_i < 1

                    if(product.errors.empty? and product.valid?)
                        product.save
                        product.update_attribute(:image_url, "/products/#{product.id}.png")
                        n=n+1
                        GC.start if n%50==0
                    end
                end
            end
            if n==0
              flash[:notice] = "Uploaded file has the wrong columns. Plz. fix & re-upload"
            else
              flash[:notice]="Uploaded your file!"
              redirect_to root_path
            end
        else
            flash[:error]="Plz. upload a file with the correct format"
        end
      else
        flash[:error]="Hey, please upload csv file"
      end
    end
  end

  def capsule
    if params[:id]
      @product = Product.find_by_id(params[:id])
      if @product.nil?
        redirect_to root_path
        return
      end
      @last_offer = @product.offers.last(:conditions => ["ip = ?", request.remote_ip])
      if request.post?
        if @last_offer and @last_offer.accepted?
          return
        end
        if params[:submit_button]
          submit = params[:submit_button].strip.downcase
          if ["yes", "no"].include? submit
            if submit == "no"
              @last_offer.update_attribute(:response, "rejected")
              flash[:error] = "Sorry we can't make a deal right now. Try again later?"
            elsif submit == "yes"
              @last_offer.update_attribute(:response, "accepted")
              flash[:notice] = "Cool, come on down to the store!"
            end
            for offer in @product.offers.all(:conditions => ["ip = (?) and id < ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, @last_offer.id])
              offer.update_attribute(:response, "expired") unless ["paid", "accepted", "rejected"].include? offer.response
            end
            return
          end
        end
        price = params[:price].to_i
        if price <= 0
            flash[:error] = "Hi, please enter a non-zero number and we can play"
        else
            avg_offer = @product.offers.last(:select => "AVG(price) as avg_price", :conditions => ["response = ?", 'paid'])
            if avg_offer.avg_price.nil?
              if @product.ticketed_retail.to_f == 49.5
                @new_offer = PromotionCode::PRICE_CODES_50[rand(999)%PromotionCode::PRICE_CODES_50.size]
              else
                @new_offer = PromotionCode::PRICE_CODES_60[rand(999)%PromotionCode::PRICE_CODES_60.size]
              end
            else
              if @product.ticketed_retail.to_f == 49.5
                if avg_offer.avg_price.to_f < 30
                  @new_offer = PromotionCode::PRICE_CODES_50[rand(999)%PromotionCode::PRICE_CODES_50.size]
                else
                  @new_offer = PromotionCode::PRICE_CODES_MIN[rand(999)%PromotionCode::PRICE_CODES_MIN.size]
                end
              else
                if avg_offer.avg_price.to_f < 35
                  @new_offer = PromotionCode::PRICE_CODES_60[rand(999)%PromotionCode::PRICE_CODES_60.size]
                else
                  @new_offer = PromotionCode::PRICE_CODES_MIN[rand(999)%PromotionCode::PRICE_CODES_MIN.size]
                end
              end
            end
        end
      end
    end
  end
end
