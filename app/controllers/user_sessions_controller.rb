class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def index
      redirect_to login_path
  end

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t("UserSession.created")
      redirect_to root_path
      #redirect_back_or_default user_path(current_user)
    else
      @user_session.errors.add(:password, @user_session.errors.messages[:base].join) if @user_session.errors.messages[:base]
      flash[:error]  = t("UserSession.notcreated")
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = t("UserSession.destroyed")
    #redirect_back_or_default new_user_session_url
    redirect_to root_path
  end
end
