class CreateMonthRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :month_requests do |t|
      t.integer :request_user_id
      t.integer :authorizer_user_id
      t.datetime :request_month
      t.integer :request_status, default: 0

      t.timestamps
    end
  end
end
