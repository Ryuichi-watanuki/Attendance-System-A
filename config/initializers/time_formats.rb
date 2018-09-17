# カスタムフォーマット作成
# 使用例：<=% オブジェクト.to_s(シンボル) %>
# to_s の入れ忘れに注意

# 例：8.00（時間としては８時）
Time::DATE_FORMATS[:time] = "%-H時%M分"

# 例：01/01（１月１日）
Date::DATE_FORMATS[:date] = "%m/%d"

# 例：1/01 （月は頭０消し）
Date::DATE_FORMATS[:day] = "%-m/%d"

# 例：2018年1月（月は頭０消し）
Date::DATE_FORMATS[:month] = "%Y年%-m月"

# 時間と分取り出し用（メソッドあるから要らんかったかも）
Time::DATE_FORMATS[:hour] = "%H"
Time::DATE_FORMATS[:minute] = "%M"

# 使わない？
Time::DATE_FORMATS[:times] = "%Y年%m月%d日 %H時%M分%S秒"