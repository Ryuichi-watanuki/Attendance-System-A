class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :admin_user,     only: [:index,:edit_basic_info, :destroy]
  before_action :correct_or_admin_user,   only: [:edit, :update]
  
  
  def show
    if not (current_user.admin? || current_user.id == @user.id)
      flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
      redirect_to current_user
    end
    
    @user = User.find(params[:id])
    params[:display_mode].nil? ? @display_month = true : @display_month = false # 表示切り替えパラメータを受け取っているか
    @weeks = %w{日 月 火 水 木 金 土}
    !params[:first_day].nil? ? @first_day = Date.parse(params[:first_day]) : @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month # 月の初日と締日の取得OK
    
    (@first_day..@last_day).each do |day|
      if not @user.attendances.any? { |obj| obj.attendance_day == day }
        date = Attendance.new(user_id: @user.id, attendance_day: day)
        date.save
      end
    end
    
    if @display_month == true
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', @first_day, @last_day).order('attendance_day')
    else
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?', @first_day, @last_day).order('attendance_day').paginate(page: params[:page], per_page: 7)
    end
    
    i = 0
    @days.each do |d|
      if d.time_in.present? && d.time_out.present?
        second = 0
        second = times(d.time_in,d.time_out)
        @total_time = @total_time.to_i + second.to_i
        i += 1
      end
    end
    @attendances_count = i
    
    @not_myself_boss_users = User.where.not(id: @user.id, boss:false) # 自分以外の上長ユーザ
    
    @month_request = MonthRequest.new(request_user_id: @user.id,request_month: @first_day) # 申請時新規作成
    
  end
  
  def display_mode_change
    @user = User.find(params[:id])
    !params[:first_day].nil? ? @first_day = Date.parse(params[:first_day]) : @first_day = Date.current.beginning_of_month
    redirect_to user_path(id: @user.id, display_mode: "weeks", first_day: @first_day) # 切り替えワードをパラメータで渡す
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
  
  def month_request
    
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

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "消去しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
    if params[:id].nil?
      @user  = User.find(current_user.id)
    else
      @user  = User.find(params[:id])
    end
  end
  
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
    
    # CSVフォーマットのダウンロード
    def csv_format_download
      csv_date = CSV.generate(encoding: Encoding::SJIS, row_sep: "\r\n", force_quotes: true) do |csv|
        csv_header = ["ID","氏名","メールアドレス","所属","社員番号","カードID","基本時間","指定勤務開始時間","指定勤務終了時間","上長フラグ","管理者フラグ","パスワード"]
        csv << csv_header
      end
      send_data(csv_date,{filename: "users_format.csv", type: 'text/csv; charset=shift_jis'})
    end
    
end

