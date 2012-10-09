class PhotoController < ApplicationController

  def up_photo
    # params: user_id, password, user_route_id, user_photo_id, photo_lon, photo_lat, shoot_time, memo, geo_tag, date, photo_data
    log = Photolog.new
    binding.pry
    status = log.up_photo(params)
    render :json => @json
  end
  
  def view_log
  end


end
