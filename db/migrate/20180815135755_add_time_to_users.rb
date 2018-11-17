class AddTimeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :basic_time, :datetime
    add_column :users, :specified_start_time, :datetime
    add_column :users, :specified_end_time, :datetime
    add_column :users, :employee_number, :integer
    add_column :users, :card_id, :string
  end
end
