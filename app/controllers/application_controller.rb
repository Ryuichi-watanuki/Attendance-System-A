require 'date'
require 'csv'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include UsersHelper
  
  private
    
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def correct_or_admin_user
      @user = User.find(params[:id])
      if not current_user?(@user) and not current_user.admin?
        redirect_to(root_url)
      end
    end
    
end