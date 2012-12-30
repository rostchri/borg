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
      logo = "flagging/aspectratio/" + if fVideoAspect >= 1.33 && fVideoAspect < 1.37
        "1.33"
      elsif fVideoAspect < 1.43
        "1.37"
      elsif fVideoAspect < 1.44
        "1.43"
      elsif fVideoAspect < 1.50
        "1.44"
      elsif fVideoAspect < 1.56
        "1.50"
      elsif fVideoAspect < 1.57
        "1.56"
      elsif fVideoAspect < 1.66
        "1.57"
      elsif fVideoAspect < 1.67
        "1.66"
      elsif fVideoAspect < 1.75
        "1.67"
      elsif fVideoAspect < 1.77
        "1.75"
      elsif fVideoAspect < 1.78
        "1.77"
      elsif fVideoAspect < 1.81
        "1.78"
      elsif fVideoAspect < 1.85
        "1.81"
      elsif fVideoAspect < 2.00
        "1.85"
      elsif fVideoAspect < 2.20
        "2.00"
      elsif fVideoAspect < 2.21
        "2.20"
      elsif fVideoAspect < 2.33
        "2.21"
      elsif fVideoAspect < 2.35
        "2.33"
      elsif fVideoAspect < 2.37
        "2.35"
      elsif fVideoAspect < 2.39
        "2.37"
      elsif fVideoAspect < 2.40
        "2.39"
      elsif fVideoAspect < 2.55
        "2.40"
      elsif fVideoAspect < 2.56
        "2.55"
      elsif fVideoAspect < 2.59
        "2.56"
      elsif fVideoAspect < 2.66
        "2.59"
      elsif fVideoAspect < 2.67
        "2.66"
      elsif fVideoAspect < 2.76
        "2.67"
      elsif fVideoAspect < 3.00
        "2.76"
      elsif fVideoAspect < 4.00
        "3.00"
      elsif fVideoAspect < 4.1
        "4.00"
      else
        printf "### Warning: No aspectratio-logo available for %s\n", file.filenames
      end + ".png"
      return logo 
    else
      printf "### Warning: No Aspect-Ratio for %s\n", file.filenames
    end
  end
  
end