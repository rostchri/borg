class Streamdetail < ActiveRecord::Base
  set_table_name "streamdetails" 
  self.primary_key = 'idFile'
  belongs_to :file, :foreign_key => "idFile", :class_name => Mediafile.name
  
  def video_codec_logo
    unless strVideoCodec.nil? || strVideoCodec.empty?
      logo = "flagging/video/#{strVideoCodec}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      #printf "### Warning: No video-codec for %s\n", file.filenames
    end
  end

  def audio_codec_logo
    unless strAudioCodec.nil? || strAudioCodec.empty?
      logo = "flagging/audio/#{strAudioCodec}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      #printf "### Warning: No audio-codec for %s\n", file.filenames
    end
  end


  def video_resolution_logo
    unless iVideoHeight.nil?
      logo = "flagging/video/"
      if iVideoHeight < 720 && iVideoWidth < 1280 
        # SD
        if iVideoHeight >= 240 && iVideoHeight < 360
          logo += "240.png"
        elsif iVideoHeight < 480
          logo += "360.png"
        elsif iVideoHeight < 540
          logo += "480.png"
        elsif iVideoHeight < 576
          logo += "540.png"
        else
          logo += "576.png"
        end
      elsif (iVideoHeight >= 720 && iVideoWidth < 1920) || (1280 <= iVideoWidth < 1920)
        # HD: 720
        logo += "720.png"
      else #iVideoWidth >= 1920
        # HD: 1080
        logo += "1080.png"
      end
      return logo
    else
      #printf "### Warning: No video-resolution for %s\n", file.filenames
    end
  end

  def audio_channels_logo
    unless iAudioChannels.nil?
      logo = "flagging/audio/#{iAudioChannels}.png"
      return logo if File.exists?("#{Rails.root}/app/assets/images/#{logo}")
    else
      #printf "### Warning: No audio-channels for %s\n", file.filenames
    end
  end

  def aspect_ratio_logo
    unless fVideoAspect.nil?
      logo = "flagging/aspectratio/"
      if fVideoAspect >= 1.33 && fVideoAspect < 1.37
        logo += "1.33.png"
      elsif fVideoAspect < 1.43
        logo += "1.37.png"
      elsif fVideoAspect < 1.44
        logo += "1.43.png"
      elsif fVideoAspect < 1.50
        logo += "1.44.png"
      elsif fVideoAspect < 1.56
        logo += "1.50.png"
      elsif fVideoAspect < 1.57
        logo += "1.56.png"
      elsif fVideoAspect < 1.66
        logo += "1.57.png"
      elsif fVideoAspect < 1.67
        logo += "1.66.png"
      elsif fVideoAspect < 1.75
        logo += "1.67.png"
      elsif fVideoAspect < 1.77
        logo += "1.75.png"
      elsif fVideoAspect < 1.78
        logo += "1.77.png"
      elsif fVideoAspect < 1.81
        logo += "1.78.png"
      elsif fVideoAspect < 1.85
        logo += "1.81.png"
      elsif fVideoAspect < 2.00
        logo += "1.85.png"
      elsif fVideoAspect < 2.20
        logo += "2.00.png"
      elsif fVideoAspect < 2.21
        logo += "2.20.png"
      elsif fVideoAspect < 2.33
        logo += "2.21.png"
      elsif fVideoAspect < 2.35
        logo += "2.33.png"
      elsif fVideoAspect < 2.37
        logo += "2.35.png"
      elsif fVideoAspect < 2.39
        logo += "2.37.png"
      elsif fVideoAspect < 2.40
        logo += "2.39.png"
      elsif fVideoAspect < 2.55
        logo += "2.40.png"
      elsif fVideoAspect < 2.56
        logo += "2.55.png"
      elsif fVideoAspect < 2.59
        logo += "2.56.png"
      elsif fVideoAspect < 2.66
        logo += "2.59.png"
      elsif fVideoAspect < 2.67
        logo += "2.66.png"
      elsif fVideoAspect < 2.76
        logo += "2.67.png"
      elsif fVideoAspect < 3.00
        logo += "2.76.png"
      elsif fVideoAspect < 4.00
        logo += "3.00.png"
      elsif fVideoAspect < 4.1
        logo += "4.00.png"
      else
        #printf "### Warning: No aspectratio-logo available for %s\n", file.filenames
        logo = nil
      end 
      return logo 
    else
      #printf "### Warning: No Aspect-Ratio for %s\n", file.filenames
    end
  end
  
end