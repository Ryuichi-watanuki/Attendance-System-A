module ApplicationHelper
  
   # ページごとの完全なタイトルを返します。
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
  
  def attendance_time_now
    DateTime.new(
      DateTime.now.year,
      DateTime.now.month,
      DateTime.now.day,
      DateTime.now.hour,
      DateTime.now.min,0
      )
  end
  
  # 半角英数字を全角に変換 
  def half_to_full(str)
    str.tr('0-9a-zA-Z', '０-９ａ-ｚＡ-Ｚ')
  end
  
  # 全角英数字を半角に変換
  def full_to_half(str)
    str.tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
  end


end
