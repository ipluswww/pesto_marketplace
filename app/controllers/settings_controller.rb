require 'date'
require 'oauth'
require 'etsy'

class SettingsController < ApplicationController

  before_filter :except => :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter EnsureCanAccessPerson.new(:person_id, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), except: :unsubscribe

  def show
    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    add_location_to_person!(target_user)
    flash.now[:notice] = t("settings.profile.image_is_processing") if target_user.image.processing?
    @selected_left_navi_link = "profile"
    render locals: {target_user: target_user}
  end

  def account
    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "account"
    target_user.emails.build
    has_unfinished = TransactionService::Transaction.has_unfinished_transactions(target_user.id)

    render locals: {has_unfinished: has_unfinished, target_user: target_user}
  end

  def notifications
    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "notifications"
    render locals: {target_user: target_user}
  end

  def apps
    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "apps"
    render locals: {target_user: target_user}
  end

  def do_etsy_authorization
    @callback_url   = return_etsy_authorization_person_settings_path
    @consumer_key    = 'ri6jzs9jkwlf09ipma5ld60j'
    @consumer_secret = 'sd0un6wwa3'
    request_token_endpoint = "https://openapi.etsy.com/v2/oauth/request_token?scope=email_r%20listings_r"

    Etsy.protocol = "https"
    Etsy.api_key = @consumer_key
    Etsy.api_secret = @consumer_secret
    Etsy.callback_url = @callback_url

    request_token = Etsy.request_token

    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret

    redirect_to Etsy.verification_url
  end

  def return_etsy_authorization
    if (session[:request_token].nil? || session[:request_secret].nil? || params[:oauth_verifier].nil?)
      return
    end 
    
    @verifier = params[:oauth_verifier]

    access = Etsy.access_token(session[:request_token], session[:request_secret], @verifier)

    access_token  = access.token
    access_secret = access.secret
    
    Etsy.api_key = @consumer_key 
    Etsy.api_secret = @consumer_secret
    
    user = Etsy.myself(access_token, access_secret)
    
    # Start finding listings.
    listings = nil

    for i in 0..3
      listings = Etsy::Listing.find_all_by_shop_id(user.shop.id, :limit => 99999)
      if !listings.nil? then
        puts "#{i} get Success"
        break
      end
    end
    #Etsy::Listing.find_all_by_shop_id('NeedlesOfSvetlana', :limit => 5)

    
    # insert listings into user store

    listings.each do |new_listing|
      add_listing(new_listing)
    end

    @current_user.app_etsy_api_key = "connected"
    @current_user.save

    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "apps"
    render locals: {target_user: target_user}
  end

  def test_return_etsy_authorization
    @consumer_key    = 'ri6jzs9jkwlf09ipma5ld60j'
    @consumer_secret = 'sd0un6wwa3'
    
    Etsy.api_key = @consumer_key 
    Etsy.api_secret = @consumer_secret
    
    user = Etsy.user('63547260')
    
    listings = nil

    for i in 0..3
      listings = Etsy::Listing.find_all_by_shop_id(user.shop.id, :limit => 3)
      if !listings.nil? then
        puts "#{i} get Success"
        break
      end
    end
    
    # insert listings into user store

    listings.each do |new_listing|
      add_listing(new_listing)
    end

    @body_class_name         = "people-settings"
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "apps"
    render locals: {target_user: target_user}
  end

  def unsubscribe
    target_user = find_person_to_unsubscribe(@current_user, params[:auth])

    if target_user && target_user.username == params[:person_id] && params[:email_type].present?
      if params[:email_type] == "community_updates"
        MarketplaceService::Person::Command.unsubscribe_person_from_community_updates(target_user.id)
      elsif [Person::EMAIL_NOTIFICATION_TYPES, Person::EMAIL_NEWSLETTER_TYPES].flatten.include?(params[:email_type])
        target_user.preferences[params[:email_type]] = false
        target_user.save!
      else
        render :unsubscribe, :status => :bad_request, locals: {target_user: target_user, unsubscribe_successful: false} and return
      end
      render :unsubscribe, locals: {target_user: target_user, unsubscribe_successful: true}
    else
      render :unsubscribe, :status => :unauthorized, locals: {target_user: target_user, unsubscribe_successful: false}
    end
  end

  private

  def add_listing(new_listing) 
    shapes = get_shapes
    params[:listing] = {}

    params[:listing][:listing_shape_id]           = shapes.first[:id]
    params[:listing][:title]                      = new_listing.title
    params[:listing][:price]                      = new_listing.price
    params[:listing][:delivery_methods]           = ["shipping"]
    params[:listing][:shipping_price]             = "0"
    params[:listing][:shipping_price_additional]  = "0"
    params[:listing][:description]                = new_listing.description
    params[:listing][:origin]                     = "161 Chrystie St, New York, NY 10002, USA"
    params[:listing][:origin_loc_attributes]      = {"address"=>"161 Chrystie St, New York, NY 10002, USA", 
     "google_address"=>"161 Chrystie St, New York, NY 10002, USA", 
     "latitude"=>"40.7206044", 
     "longitude"=>"-73.99292100000002"
    }

    params[:listing][:category_id]                = 3
    
    params[:custom_fields]   = {}
    params[:listing_images]  = [{"id"=>""}, {"id"=>""}, {"id"=>""}]

    params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank?

    shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create

    if shape.present? && shape[:availability] == :booking
      bookable_res = create_bookable(@current_community.uuid_object, listing_uuid, @current_user.uuid_object)
      unless bookable_res.success
        flash[:error] = t("listings.error.create_failed_to_connect_to_booking_service")
        return false
      end
    end

    # with_currency = params[:listing].merge({currency: @current_community.currency})
    with_currency = params[:listing].merge({currency: new_listing.currency})
    valid_until_enabled = !@current_community.hide_expiration_date
    listing_params = ListingFormViewUtils.filter(with_currency, shape, valid_until_enabled)
    listing_unit = Maybe(params)[:listing][:unit].map { |u| ListingViewUtils::Unit.deserialize(u) }.or_else(nil)
    listing_params = ListingFormViewUtils.filter_additional_shipping(listing_params, listing_unit)
    validation_result = ListingFormViewUtils.validate(
      params: listing_params,
      shape: shape,
      unit: listing_unit,
      valid_until_enabled: valid_until_enabled
    )

    unless validation_result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: validation_result.data.join(', '))
      return false
    end

    listing_params = normalize_price_params(listing_params)
    m_unit = select_unit(listing_unit, shape)

    listing_params = create_listing_params(listing_params).merge(
        uuid_object: listing_uuid,
        community_id: @current_community.id,
        listing_shape_id: shape[:id],
        transaction_process_id: shape[:transaction_process_id],
        shape_name_tr_key: shape[:name_tr_key],
        action_button_tr_key: shape[:action_button_tr_key],
        availability: shape[:availability]
    ).merge(unit_to_listing_opts(m_unit)).except(:unit)

    @listing = Listing.new(listing_params)

    ActiveRecord::Base.transaction do

      @listing.author = @current_user      

      if @listing.save
        upsert_field_values!(@listing, params[:custom_fields])

        listing_image_ids =
          if params[:listing_images]
            params[:listing_images].collect { |h| h[:id] }.select { |id| id.present? }
          else
            logger.error("Listing images array is missing", nil, {params: params})
            []
          end

        ListingImage.where(id: listing_image_ids, author_id: @current_user.id).update_all(listing_id: @listing.id)

        Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))
        if @current_community.follow_in_use?
          Delayed::Job.enqueue(NotifyFollowersJob.new(@listing.id, @current_community.id), :run_at => NotifyFollowersJob::DELAY.from_now)
        end

        flash[:notice] = t(
          "layouts.notifications.listing_created_successfully",
          :new_listing_link => view_context.link_to(t("layouts.notifications.create_new_listing"),new_listing_path)
        ).html_safe

        # Onboarding wizard step recording
        state_changed = Admin::OnboardingWizard.new(@current_community.id)
          .update_from_event(:listing_created, @listing)
        if state_changed
          report_to_gtm({event: "km_record", km_event: "Onboarding listing created"})

          flash[:show_onboarding_popup] = true
        end

        if shape[:availability] == :booking
          return true
        end

        return true
      else
        logger.error("Errors in creating listing: #{@listing.errors.full_messages.inspect}")
        flash[:error] = t(
          "layouts.notifications.listing_could_not_be_saved",
          :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")
        ).html_safe
        return false
      end
    end
  end  

  private

  def add_location_to_person!(person)
    unless person.location
      person.build_location(:address => person.street_address)
      person.location.search_and_fill_latlng
    end
    person
  end

  # Note! Requires that parent listing is already saved to DB. We
  # don't use association to link to listing but directly connect to
  # listing_id.
  def upsert_field_values!(listing, custom_field_params)
    custom_field_params ||= {}

    # Delete all existing
    custom_field_value_ids = listing.custom_field_values.map(&:id)
    CustomFieldOptionSelection.where(custom_field_value_id: custom_field_value_ids).delete_all
    CustomFieldValue.where(id: custom_field_value_ids).delete_all

    field_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(listing.id, custom_field_id, answer_value) unless is_answer_value_blank(answer_value)
    end.compact

    # Insert new custom fields in a single transaction
    CustomFieldValue.transaction do
      field_values.each(&:save!)
    end
  end

  def create_listing_params(params)
    listing_params = params.except(:delivery_methods).merge(
      require_shipping_address: Maybe(params[:delivery_methods]).map { |d| d.include?("shipping") }.or_else(false),
      pickup_enabled: Maybe(params[:delivery_methods]).map { |d| d.include?("pickup") }.or_else(false),
      price_cents: params[:price_cents],
      shipping_price_cents: params[:shipping_price_cents],
      shipping_price_additional_cents: params[:shipping_price_additional_cents],
      currency: params[:currency]
    )

    add_location_params(listing_params, params)
  end

  def add_location_params(listing_params, params)
    if params[:origin_loc_attributes].nil?
      listing_params
    else
      location_params = params[:origin_loc_attributes].permit(
        :address,
        :google_address,
        :latitude,
        :longitude
      ).merge(
        location_type: :origin_loc
      )

      listing_params.merge(
        origin_loc_attributes: location_params
      )
    end
  end

  def select_unit(listing_unit, shape)
    m_unit = Maybe(shape)[:units].map { |units|
      units.length == 1 ? units.first : units.find { |u| u == listing_unit }
    }
  end

  def unit_to_listing_opts(m_unit)
    m_unit.map { |unit|
      {
        unit_type: unit[:type],
        quantity_selector: unit[:quantity_selector],
        unit_tr_key: unit[:name_tr_key],
        unit_selector_tr_key: unit[:selector_tr_key]
      }
    }.or_else({
        unit_type: nil,
        quantity_selector: nil,
        unit_tr_key: nil,
        unit_selector_tr_key: nil
    })
  end

  def unit_from_listing(listing)
    HashUtils.compact({
      type: Maybe(listing.unit_type).to_sym.or_else(nil),
      quantity_selector: Maybe(listing.quantity_selector).to_sym.or_else(nil),
      unit_tr_key: listing.unit_tr_key,
      unit_selector_tr_key: listing.unit_selector_tr_key
    })
  end

  def build_title(params)
    category = Category.find_by_id(params["category"])
    category_label = (category.present? ? "(" + localized_category_label(category) + ")" : "")

    listing_type_label = if ["request","offer"].include? params['share_type']
      t("listings.index.#{params['share_type']+"s"}")
    else
      t("listings.index.listings")
    end

    t("listings.index.feed_title",
      :optional_category => category_label,
      :community_name => @current_community.name_with_separator(I18n.locale),
      :listing_type => listing_type_label)
  end

  def numeric_field_ids(custom_fields)
    custom_fields.map do |custom_field|
      custom_field.with(:numeric) do
        custom_field.id
      end
    end.compact
  end

  def normalize_price_params(listing_params)
    currency = listing_params[:currency]
    listing_params.inject({}) do |hash, (k, v)|
      case k
      when "price"
        hash.merge(:price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price"
        hash.merge(:shipping_price_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      when "shipping_price_additional"
        hash.merge(:shipping_price_additional_cents =>  MoneyUtil.parse_str_to_subunits(v, currency))
      else
        hash.merge(k.to_sym => v)
      end
    end
  end

  def create_bookable(community_uuid, listing_uuid, author_uuid)
    res = HarmonyClient.post(
      :create_bookable,
      body: {
        marketplaceId: community_uuid,
        refId: listing_uuid,
        authorId: author_uuid
      },
      opts: {
        max_attempts: 3
      })

    if !res[:success] && res[:data][:status] == 409
      Result::Success.new("Bookable for listing with UUID #{listing_uuid} already created")
    else
      res
    end
  end

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

  def listings_api
    ListingService::API::Api
  end

  def transactions_api
    TransactionService::API::Api
  end

  def valid_unit_type?(shape:, unit_type:)
    if unit_type.nil?
      shape[:units].empty?
    else
      shape[:units].any? { |unit| unit[:type] == unit_type.to_sym }
    end
  end

  def get_shapes
    @shapes ||= listings_api.shapes.get(community_id: @current_community.id).maybe.or_else(nil).tap { |shapes|
      raise ArgumentError.new("Cannot find any listing shape for community #{@current_community.id}") if shapes.nil?
    }
  end

  def get_processes
    @processes ||= transactions_api.processes.get(community_id: @current_community.id).maybe.or_else(nil).tap { |processes|
      raise ArgumentError.new("Cannot find any transaction process for community #{@current_community.id}") if processes.nil?
    }
  end

  def get_shape(listing_shape_id)
    shape_find_opts = {
      community_id: @current_community.id,
      listing_shape_id: listing_shape_id
    }

    shape_res = listings_api.shapes.get(shape_find_opts)

    if shape_res.success
      shape_res.data
    else
      raise ArgumentError.new(shape_res.error_msg) unless shape_res.success
    end
  end
end
