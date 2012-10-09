class Photolog < ActiveRecord::Base

  self.table_name = "sanpo_photos"

  def up_photo(params)
    
    user_id = params[:user_id]
    password = params[:password]
    user_route_id = params[:user_route_id]
    user_photo_id = params[:user_photo_id]
    photo_lon = params[:photo_lon]
    photo_lat = params[:photo_lat]
    shoot_time = params[:shoot_time]
    memo = params[:memo]
    geo_tag = params[:geo_tag]
    date = params[:date]
    photo_data = params[:photo_data]
    
    # If password provided by the querier is incorrect, reject query
    if password != date[0..3] + user_id.reverse + date[4..5]
      return "Error: password incorrect"
    end
    
    # Save the photo to a file with filename being the id of the photo
    
    # Create entry in DB for this photo
    PhotoLog.connection.execute("INSERT INTO sanpo_photos(id, user_id, user_route_id)")
    
   
  end
end
