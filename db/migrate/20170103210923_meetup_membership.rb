class MeetupMembership < ActiveRecord::Migration
  def change
    create_join_table :users, :meetups, table_name: :meetup_memberships do |table|
      table.index :user_id
      table.index :meetup_id
    end
  end
end
