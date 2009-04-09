class Dealer < ActiveRecord::Base
  has_many :accounts #an umbrella to aggregate accounts together
  has_and_belongs_to_many :users #optional relationship, to grant users access to view multiple dealers
end
