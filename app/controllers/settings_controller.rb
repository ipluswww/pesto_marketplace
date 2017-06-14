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
    listings = Etsy::Listing.find_all_by_shop_id(user.shop.id, :limit => 5)
    #Etsy::Listing.find_all_by_shop_id('NeedlesOfSvetlana', :limit => 5)



  end

  def test_return_etsy_authorization
    debugger
    @consumer_key    = 'ri6jzs9jkwlf09ipma5ld60j'
    @consumer_secret = 'sd0un6wwa3'
    
    Etsy.api_key = @consumer_key 
    Etsy.api_secret = @consumer_secret
    
    user = Etsy.user('63547260')
    
    listings = nil

    for i in 0..3
      listings = Etsy::Listing.find_all_by_shop_id(user.shop.id, :limit => 5)
      if !listings.nil? then
        puts "#{i} get Success"
        break
      end
    end
    

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

  def add_location_to_person!(person)
    unless person.location
      person.build_location(:address => person.street_address)
      person.location.search_and_fill_latlng
    end
    person
  end

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
