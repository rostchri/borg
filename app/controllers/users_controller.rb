# -*- encoding : utf-8 -*-
class UsersController <  ResourcesController
  before_filter :store_location, only: [:show,:index]
      
  # def show
  #   @user = User.find(params[:id] ? params[:id] : current_user)
  #   show!
  # end
  # 
  # def edit
  #   @user = User.find(params[:id] ? params[:id] : current_user)
  #   edit!
  # end
  # 
  # def create
  #   @user = User.new
  #   @user.assign_attributes(params[:user], :as => (current_user.nil? ? User::access_key([:guest]) : current_user.access_key) )
  #   # Saving without session maintenance to skip auto-login which can't happen here because the User has not yet been activated
  #   if @user.save_without_session_maintenance
  #     @user.send_activation_instructions!
  #     flash[:success] = t("#{resource_class}.created", :name => @user, :email => @user.email)
  #     redirect_to session[:return_to]
  #   else
  #     flash[:error] = t("#{resource_class}.notcreated")
  #     create!{session[:return_to]}
  #   end
  # end
  

  protected
    # def update_resource(object, attributes)
    #   #printf "UPDATING user #{@user.login} with access-key: #{current_user.access_key}\n"
    #   if object.update_attributes(*attributes,  :as => current_user.access_key)
    #     flash[:success] =  t("#{resource_class}.updated", :name => @user)
    #   end
    # end
    #   
    # def set_breadcrumb
    #   add_crumb resource_class.model_name.human(:count=>2), (permitted_to?(:index) ? collection_path : :nolink)
    #   unless params[:id].nil?
    #     resource = resource_class.find(params[:id])
    #     add_crumb resource, user_path
    #     add_crumb t "edit", :scope=>[:views,:breadcrumb] if ["edit","update"].include?(params[:action])
    #   else
    #     if !current_user.nil? && !["new","create"].include?(params[:action])
    #       add_crumb current_user, account_path unless params[:action] == "index"
    #       add_crumb t "edit", :scope=>[:views,:breadcrumb] if ["edit","update"].include?(params[:action])
    #     else
    #       add_crumb t("register")
    #     end
    #   end
    # end
  
end
