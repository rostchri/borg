class Streamdetail < ActiveRecord::Base
  set_table_name "streamdetails" 
  self.primary_key = 'idFile'
  belongs_to :file, :foreign_key => "idFile", :class_name => Mediafile.name
  
  def video_codec_logo
    case strVideoCodec
    when "xvid" 
      "xvid.png"
    when "mpeg2video"
      "mpeg2video.png"
    when "mpeg1video"
      "mpeg1video.png"
    when "h264"
      "h264.png"
    when "div3"
      "divx.png"
    when "mpg4"
      "mpg4.png"
    else
      printf "### Warning: No codec for %s\n", file.filenames
    end
  end


  def aspect_ratio_logo
    unless fVideoAspect.nil?
      "#{fVideoAspect}"[0..3]  + ".png"
    else
      printf "### Warning: No Aspect-Ratio for %s\n", file.filenames
    end
  end
  
end