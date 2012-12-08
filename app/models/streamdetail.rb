class Streamdetail < ActiveRecord::Base
  set_table_name "streamdetails" 
  self.primary_key = 'idFile'
  belongs_to :file, :foreign_key => "idFile", :class_name => Mediafile.name
end