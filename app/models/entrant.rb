class Entrant < ActiveRecord::Base
  paginates_per 10
  default_scope order("date DESC", :category, :title)
  
  scope :by_category, ->(categories) {{:conditions =>["category in (?)",categories]}}
  scope :by_date,     ->(dates)      {{:conditions =>["date in (?)",dates]}}
  scope :by_type,     ->(types)      {{:conditions =>["type in (?)",types]}}
  
  scope :sum_and_group_by_date_and_category, :select => "COUNT(*) AS count, date, category", :group => "date,category", :order => "count, date, category"

  serialize :other, Hash
  attr_accessible :title, :srcid, :other, :date, :category, :srcurl, :thumbnail
  validates_presence_of :srcid
  has_attached_file :thumbnail, :storage => :s3, :s3_credentials => S3_SETTINGS, :url  => ":s3_eu_url", :path => "#{Rails.env}/:class/:id/:basename_:style.:extension"
end