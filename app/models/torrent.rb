class Torrent < ActiveRecord::Base
  paginates_per 10
  default_scope order(:timestamp)  
  serialize :detail, Hash
  attr_accessible :title, :srcid, :detail, :timestamp
  validates_presence_of :srcid
end