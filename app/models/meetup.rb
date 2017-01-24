class Meetup < ActiveRecord::Base
  has_many :users, through: :meetup_memberships
  has_many :meetup_memberships
end
