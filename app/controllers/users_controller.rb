require "date"
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  # before_action :correct_user,   only: [:edit, :update]
  before_action :correct_or_admin_user,   only: [:edit, :update]
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
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', @first_day, @last_day).order('attendance_day')
      
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
    time_in = DateTime.new(
      DateTime.now.year,
      DateTime.now.month,
      DateTime.now.day,
      DateTime.now.hour,
      DateTime.now.min,0
      )
    @time_in.update_attributes(time_in: time_in) 
    flash[:info] = "おはようございます。"
    redirect_to @user
  end

  # 退社時間登録
  def time_out
    @user = User.find(params[:id])
    @time_out = @user.attendances.find_by(attendance_day: Date.current)
    timeout = DateTime.new(
      DateTime.now.year,
      DateTime.now.month,
      DateTime.now.day,
      DateTime.now.hour,
      DateTime.now.min,0
    )
    @time_out.update_attributes(time_out: timeout)
    flash[:info] = "お疲れ様でした。"
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
    @users = @q.result.paginate(page: params[:page], per_page: 20)
    
    respond_to do |format|
      format.html
      format.csv do
        if params[:download_type].present? && params[:download_type] == "format"
          # フォーマットダウンロードの場合
          csv_format_download
        else
          # 一覧ダウンロードの場合
          # csv_download
        end
      end
    end
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
  
  # CSVインポート
  def csv_import
    success_count = 0
    # エラー情報
    error = ""
    begin
      # windowsで作られたファイルに対応するので、encoding: "SJIS"を付けている
      unless params[:users_file].nil?
        CSV.foreach(params[:users_file].path, headers: true, encoding: "SJIS") do |row|
          user = User.find_by(email: row["メールアドレス"])
          # 既存のemailがなければ新規登録
          user = User.new if user.blank?
          if user.update({ name: row["ユーザー名"],
            email: row["メールアドレス"],
            affiliation: row["所属"],
            employee_number: row["社員番号"],
            card_id: row["カードID"],
            basic_time: row["基本時間"],
            specified_start_time: row["指定勤務開始時間"],
            specified_end_time: row["指定勤務終了時間"],
            boss: row["上長フラグ"],
            admin: row["管理者フラグ"],
            password: row["パスワード"]})
            success_count += 1
          else
            # エラーの場合はメッセージを格納する
            error += "ユーザ名（#{user.name}）:#{user.errors.full_messages.join(", ")}<br>"
          end
        end
      else
        flash[:warning] = 'ファイルが選択されていません'
        redirect_to users_path
        return
      end
      
      if error.blank?
        flash[:success] = '登録に成功しました'
        redirect_to users_path
      else
        # 登録件数があれば表示
        flash[:success] = "#{success_count}件登録に成功しました" if success_count > 0
        flash[:danger] = error
        redirect_to users_path
      end
    rescue
      flash[:danger] = '登録に失敗しました'
      redirect_to users_path
    end
  end
  
  private

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :employee_number,
        :card_id,
        :password,
        :activated,
        :affiliation,
        :basic_time,
        :specified_start_time,
        :specified_end_time,
        :password_confirmation
      )
    end
    
    def search_params
      params.require(:q).permit(:name_cont)
    end
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # カレントユーザーがログインユーザー、もしくは管理者かを確認
    def correct_or_admin_user
      @user = User.find(params[:id])
      if not current_user?(@user) and not current_user.admin?
        flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
        redirect_to(root_url)
      end
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    # CSVフォーマットのダウンロード
    def csv_format_download
      csv_date = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
        csv_header = ["ID","氏名","メールアドレス","所属","社員番号","カードID","基本時間","指定勤務開始時間","指定勤務終了時間","上長フラグ","管理者フラグ","パスワード"]
        csv << csv_header
      end
      send_data(csv_date,{filename: "users_format.csv", type: 'text/csv; charset=shift_jis'})
    end
    
end

