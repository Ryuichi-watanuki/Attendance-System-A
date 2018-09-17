require "date"
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:index,:edit_basic_info, :destroy]
  
  
  
  # 勤怠表示画面
  def show
    @user = User.find(params[:id])
   
     
    if current_user.admin? || current_user.id == @user.id
      @week = %w{日 月 火 水 木 金 土}
      
      if not params[:first_day].nil?
        @first_day = Date.parse(params[:first_day])
      else
        @first_day = Date.current.beginning_of_month
      end
      
      @last_day = @first_day.end_of_month
      
      # 取得月の初日から終日まで繰り返し処理
      (@first_day..@last_day).each do |day|
        # attendancesテーブルに各日付のデータがあるか
        if not @user.attendances.any? { |obj| obj.attendance_day == day }
          # ない日付はインスタンスを生成して保存する
          date = Attendance.new(user_id: @user.id, attendance_day: day)
          date.save
        end
      end
      
      # 当月を昇順で取得し@daysへ代入
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', \
      @first_day, @last_day).order('attendance_day')
      
      # 在社時間の集計、ついでに出勤日数も
      i = 0
      @days.each do |d|
        if d.time_in.present? && d.time_out.present?
          second = 0
          second = times(d.time_in,d.time_out)
          @total_time = @total_time.to_i + second.to_i
          i = i + 1
        end
      end
    
      # 出勤日数、どっち使ってもOK
      @attendances_count = i
      @attendances_sum = @days.where.not(time_in: nil, time_out: nil).count
    else
      flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
      redirect_to current_user
    end
  end
  
  # 出勤時間登録
  def time_in
    @user = User.find(params[:id])
    @time_in = @user.attendances.find_by(attendance_day: Date.current)
    @time_in.update_attributes(time_in: DateTime.new(DateTime.now.year,\
    DateTime.now.month, DateTime.now.day,DateTime.now.hour,DateTime.now.min,0))
    flash[:info] = "今日も一日がんばるぞい！"
    redirect_to @user
  end

  # 退社時間登録
  def time_out
    @user = User.find(params[:id])
    @time_out = @user.attendances.find_by(attendance_day: Date.current)
    timeout = DateTime.new(DateTime.now.year,DateTime.now.month,\
    DateTime.now.day,DateTime.now.hour,DateTime.now.min,0)
    @time_out.update_attributes(time_out: timeout)
    flash[:info] = "今日も一日お疲れ様でした。"
    redirect_to @user
  end
  
  # ユーザ一覧
  def index
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = User.ransack(search_params, activated: true)
      @title = "検索結果"
    else
      @q = User.ransack(activated: true)
      @title = "全てのユーザー"
    end
    @users = @q.result.paginate(page: params[:page])
  end

  # ユーザー新規登録画面
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      # params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to @user
    else
      render 'new'
    end
  end
  
  # ユーザー情報編集画面
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # ユーザー消去  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "消去しました。"
    redirect_to users_url
  end
  
  # 基本情報編集画面
  def edit_basic_info
    # パラメータを受け取っている？
    if params[:id].nil?
      @user  = User.find(current_user.id)
    else
      @user  = User.find(params[:id])
    end
  end
  
  # 基本情報更新アクション
  def basic_info_edit
    @user  = User.find(params[:id])
    
    if @user.update_attributes(user_params)
      flash[:success] = "基本情報を更新しました。"
      redirect_to @user
    else
      redirect_to @user
    end
  end
  
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :employee_number, :password, :activated,
      :affiliation, :basic_time, :specified_start_time, :specified_end_time, :password_confirmation)
    end
    
    def search_params
      params.require(:q).permit(:name_cont)
    end
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end

