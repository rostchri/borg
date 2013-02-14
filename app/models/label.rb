class Label < ActiveRecord::Base
  
  attr_accessible :name, :description, :key
  
  has_many :tags, :dependent => :delete_all
  has_many :movies, :through => :tags, :source => :tagable, :source_type => 'Movie'
  
  validates_presence_of   :name, :key
  validates_uniqueness_of :name, :key
  
  paginates_per 20
  default_scope order(:id)
  
  def to_s
    self.name
  end
end