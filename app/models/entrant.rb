class Entrant < ActiveRecord::Base
  paginates_per 30
  #default_scope order("date DESC", "created_at DESC", :category, :title)
  default_scope order("updated_at DESC", :category, :title)
  
  scope :older_than, lambda { |date| { :conditions=>["updated_at < ?", date] } }
  scope :by_category, ->(categories) {{:conditions =>["category in (?)",categories]}}
  scope :by_date,     ->(dates)      {{:conditions =>["date in (?)",dates]}}
  scope :by_type,     ->(types)      {{:conditions =>["type in (?)",types]}}
  
  scope :sum_and_group_by_date_and_category, :select => "COUNT(*) AS count, date, category", :group => "date,category", :order => "count, date, category"

  serialize :other, Hash
  attr_accessible :title, :srcid, :other, :date, :category, :srcurl, :image, :imageurl
  validates_presence_of :srcid
  has_attached_file :image, :storage => :s3, :s3_credentials => S3_SETTINGS, :url  => ":s3_eu_url", :path => "#{Rails.env}/:class/:id/:basename_:style.:extension"
  
  before_update :counter_update

  def counter_update
     self.update_counter=self.update_counter + 1
  end
  
  def self.recycle(age = 30.days.ago)
    Entrant.older_than(age).each(&:destroy)
  end
end