class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user # always require login to access any content at this site
  layout :resolve_layout
  helper_method :current_user_session, :current_user, :controller?, :action?, :scope?
    
  def controller?(*controllers)
    !(controllers.flatten & [controller_name.to_sym]).empty?
  end
  
  def action?(*actions)
    !(actions.flatten & [action_name.to_sym]).empty?
  end
  
  def scope?(*scopes)
    !(params.keys.map{|k| k.to_sym} & scopes.flatten).empty?
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end 
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end


    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location(location = request.url)
      session[:return_to] = request.url
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def resolve_layout
      return nil if request.xhr?
      return "application_two_column_content.html.haml" if controller?(:users)
      return "application_one_column_content.html.haml"
    end
  
end
