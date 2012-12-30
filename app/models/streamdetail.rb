class Streamdetail < ActiveRecord::Base
  set_table_name "streamdetails" 
  self.primary_key = 'idFile'
  belongs_to :file, :foreign_key => "idFile", :class_name => Mediafile.name
  
  def video_codec_logo
    unless strVideoCodec.nil? || strVideoCodec.empty?
      logo = "flagging/video/#{strVideoCodec}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      printf "### Warning: No video-codec for %s\n", file.filenames
    end
  end

  def audio_codec_logo
    unless strAudioCodec.nil? || strAudioCodec.empty?
      logo = "flagging/audio/#{strAudioCodec}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      printf "### Warning: No audio-codec for %s\n", file.filenames
    end
  end

  def video_resolution_logo
    unless iVideoHeight.nil?
      logo = "flagging/video/" + if iVideoHeight >= 240 && iVideoHeight < 360
        "240"
      elsif iVideoHeight < 480
        "480"
      elsif iVideoHeight < 540
        "540"
      elsif iVideoHeight < 576
        "576"
      elsif iVideoHeight < 720
        "576"
      elsif iVideoHeight < 1080
        "1080"
      else
        printf "### Warning: No video-resolution-logo available for %s\n", file.filenames
      end + ".png"
      
      return logo
    else
      printf "### Warning: No video-resolution for %s\n", file.filenames
    end
  end

  def audio_channels_logo
    unless iAudioChannels.nil?
      logo = "flagging/audio/#{iAudioChannels}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      printf "### Warning: No audio-channels for %s\n", file.filenames
    end
  end

  def aspect_ratio_logo
    unless fVideoAspect.nil?
      logo = "flagging/aspectratio/#{fVideoAspect}"[0..3]  + ".png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      printf "### Warning: No Aspect-Ratio for %s\n", file.filenames
    end
  end
  
end