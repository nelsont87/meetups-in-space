class CreateMeetup < ActiveRecord::Migration
  def change
    create_table :meetups do |table|
      table.string :name, null: false
      table.string :location, null: false
      table.string :description, null: false
      table.string :creator, null: false
      table.string :members, unique: true

      table.timestamps null: false
    end
  end
end
