class PhotoController < ApplicationController

  def up_photo
    # params: user_id, password, user_route_id, user_photo_id, photo_lon, photo_lat, shoot_time, memo, geo_tag, date, photo_data
    log = Photolog.new
    status = log.up_photo(params)
    render :json => status
  end
  
  def view_log
  end


end
