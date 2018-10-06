class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :attendance_day
      t.datetime :time_in
      t.datetime :time_out
      t.string   :remarks
      t.references :user, foreign_key: true


      t.timestamps
    end
  end
end
