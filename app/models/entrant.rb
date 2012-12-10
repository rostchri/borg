class Entrant < ActiveRecord::Base
  paginates_per 10
  default_scope order(:date)  
  serialize :other, Hash
  attr_accessible :title, :srcid, :other, :date, :category, :srcurl, :thumbnail
  validates_presence_of :srcid
  has_attached_file :thumbnail, :storage => :s3, :s3_credentials => S3_SETTINGS, :url  => ":s3_eu_url", :path => ":class/:id/:basename_:style.:extension"
end