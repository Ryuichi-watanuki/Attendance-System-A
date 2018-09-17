require "time"
class AttendancesController < ApplicationController
  before_action :admin_user,     only: [:attendance_in]


  # 勤怠編集画面 
  def attendance_edit
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
      @days = @user.attendances.where('attendance_day >= ? and attendance_day <= ?',\
      @first_day, @last_day).order('attendance_day')
      
    else
      flash[:warning] = "他のユーザーの勤怠情報は閲覧できません。"
      redirect_to current_user
    end
  end

  # 勤怠編集画面ー更新ボタン
  def update_bunch
    @user = User.find(params[:id])
    
    attendances_params.each do |id, item|
      attendance = Attendance.find(id)
      
      #当日以降の編集はadminユーザのみ
      if attendance.attendance_day > Date.current && !current_user.admin?
        flash[:warning] = '明日以降の勤怠編集は出来ません。'
      
      elsif item["time_in"].blank? && item["time_in"].blank?

      #出社時間と退社時間の両方の存在を確認
      elsif item["time_in"].blank? || item["time_in"].blank?
        flash[:warning] = '一部編集が無効となった項目があります。'
      
      #出社時間 > 退社時間ではないか
      elsif item["time_in"].to_s > item["time_out"].to_s
        flash[:warning] = '出社時間より退社時間が早い項目がありました'
      
      else
        attendance.update_attributes(item)
        flash[:success] = '勤怠時間を更新しました。'
      end
    end #eachの締め
    redirect_to user_url(@user, params:{ id: @user.id, first_day: params[:first_day]})
  end
  
  # 出勤中社員一覧画面
  def attendance_in
    # 空のハッシュを定義
    @time_in_user = {}
    User.all.each do |user|
      # このifがよくわからなくなったらany?メソッドをおさらい
      # ブロックに記述した条件が真の場合、処理を実行する
      if user.attendances.any? { |obj| (obj.attendance_day == Date.current && obj.time_in.present? && obj.time_out.blank?) }
        # 出社時間を拾うため
        today = user.attendances.find_by(attendance_day: Date.current)
        # キーを任意の文字列で設定したら失敗した、user毎の変数で設定する。
        # eachで繰り返してるuserのidをキーに社員番号、氏名、所属、出社時間を代入
        @time_in_user[user.id] = user.employee_number, user.name, user.affiliation, today.time_in
      end
    end
  end
  
  # プライベート
  private
    
    def attendances_params
      params.permit(attendances: [:time_in, :time_out])[:attendances]
    end
    
     # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end