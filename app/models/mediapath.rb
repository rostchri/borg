class Mediapath < ActiveRecord::Base
  set_table_name "path"
  has_many :files, :foreign_key => "idPath", :class_name => Mediafile.name
  scope :sum_and_group_by_files, :include => :files, :select => "strPath", :group => "files.idPath", :having => "count(files.idFile) > 1" 

  def topdirectory
    strPath.split("/").last
  end
  
  def self.stack_movies_in_same_directory
    Mediapath.sum_and_group_by_files.each do |pathwithmultiplefiles|
      pathwithmultiplefiles = Mediapath.find(pathwithmultiplefiles.idPath)
      printf "%s\n %s\n", pathwithmultiplefiles.strPath, pathwithmultiplefiles.files.map{|f| f.strFilename}.join("\n ")
    end
    nil
  end
  
end