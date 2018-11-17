class MonthRequest < ApplicationRecord
  # 指示者確認印・・・0:なし, 1:申請中, 2:承認, 3:否認
  enum request_status: {non: 0, requesting: 1, approval: 2, denial: 3}
  
end
