class MediafilesController < ResourcesController
  
  def video_thumbnail
    image = File.open(Mediafile.video_thumbnail(params[:hash]),"rb") { |f| f.read}
    send_data image, :type => 'image/png',:disposition => 'inline'
  end

  def fanart_thumbnail
    image = File.open(Mediafile.fanart_thumbnail(params[:hash]),"rb") { |f| f.read}
    send_data image, :type => 'image/png',:disposition => 'inline'
  end
  
end

