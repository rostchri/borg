class Mediafile < ActiveRecord::Base
  set_table_name "files"
  has_one     :movie,     :foreign_key => "idFile", :class_name => Movie.name
  belongs_to  :path,      :foreign_key => "idPath", :class_name => Mediapath.name
  has_one     :settings,  :foreign_key => "idFile", :class_name => Mediasetting.name
  has_one     :details,   :foreign_key => "idFile", :class_name => Streamdetail.name
  
  VIDEOTHUMBPREFIX = "#{Rails.root}/../userdata/Thumbnails/Video"
  FANTHUMBPREFIX   = "#{Rails.root}/../userdata/Thumbnails/Video/Fanart"
  
  @thumbnail = nil
  
  def filenames
    if strFilename =~ /^stack:\/\/(.*)/
      $1.split(" , ").map{|f| f =~ /.*\/(.*$)/ ? $1 : f}
    else
      [strFilename]
    end
  end
  
  def self.crc32(string)
    string.downcase!
  	crc = 0xFFFFFFFF
  	string.each_byte do |b|
  		crc ^= (b << 24) 
  		8.times do
  		  if (crc & 0x80000000 != 0) 
          crc = (crc << 1) ^ 0x04C11DB7
        else
          crc <<=  1
        end
  		end
  		crc &=  0xFFFFFFFF
  	end
  	'%08x' % crc
  end
  
  def determine_cached_thumbnails
    if @thumbnail.nil?
      result = {}
      pathfilename = ""
      if strFilename =~ /stack:\/\/([^,]*)/
        pathfilename = $1.strip
      else
        pathfilename = path.strPath + strFilename
      end
      hash = Mediafile.crc32(pathfilename)
      result.merge!({:video  => hash}) if File.exists?(Mediafile.video_thumbnail(hash))
      result.merge!({:fanart => hash}) if File.exists?(Mediafile.fanart_thumbnail(hash))
      printf "determine_cached_thumbnails %p %p\n", self, result
      @thumbnail = result
    end
    @thumbnail
  end
  
  def fanart_thumbnail
    determine_cached_thumbnails if @thumbnail.nil?
    @thumbnail[:fanart]
  end

  def video_thumbnail
    determine_cached_thumbnails if @thumbnail.nil?
    @thumbnail[:video]
  end
  
  def self.fanart_thumbnail(hash)
    "#{FANTHUMBPREFIX}/#{hash}.tbn" unless hash.nil?
  end
  
  def self.video_thumbnail(hash)
    "#{VIDEOTHUMBPREFIX}/#{hash.first}/#{hash}.tbn" unless hash.nil?
  end
  
end