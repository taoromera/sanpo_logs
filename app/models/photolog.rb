class Photolog < ActiveRecord::Base

  self.table_name = "sanpo_photos"
  attr_accessible :photo

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
    
    user_id = check_pass(password, user_id)
    user_id.nil? ? return("Error: password incorrect") : 1
    
    # Create entry in DB for this photo
    Photolog.connection.execute("INSERT INTO #{self.table_name} VALUES (DEFAULT, '#{user_id}', #{user_route_id}, #{user_photo_id}, #{photo_lat}, #{photo_lon}, '#{[shoot_time.split('_')[0], shoot_time.split('_')[1].gsub!('-', ':')].join(' ')}', '', '#{memo}', '#{geo_tag}')")
   
    # Get the id of the created entry
    entry_id = Photolog.connection.execute("SELECT id FROM #{self.table_name} WHERE user_id = '#{user_id}' AND user_route_ID = #{user_route_id} AND user_photo_id = #{user_photo_id}").getvalue(0,0)

    # Generate filename: entry_id + random string of 25 characters
    photo_filename = entry_id + (0...25).map{ ('a'..'z').to_a[rand(26)] }.join + '.jpg'
    
    # Save the photo to a file with filename being the id of the photo
    dir = "/web_server/user_photos/#{user_id}/#{user_route_id}/"
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    File.open(dir+photo_filename, 'wb') {|f| f.write(params[:photo_data].read)}    
    
    # Insert filename into DB
    Photolog.connection.execute("UPDATE #{self.table_name} SET filename = '#{photo_filename}' WHERE id = #{entry_id}")
   
    return {:result => '1', :route_id => id, :create_time => shoot_time, :photo_url => "sanpo.mobi/user_photos/#{user_id}/#{user_route_id}/#{photo_filename}"}
  end
  
  def del_photo(params)
    
    user_id = params[:user_id]
    password = params[:password]
    user_route_id = params[:user_route_id]
    user_photo_id = params[:user_photo_id]
    date = params[:date]
    
    user_id = check_pass(password, user_id)
    user_id.nil? ? return("Error: password incorrect") : 1
    
    # Delete photo file
    filename = Photolog.connection.execute("SELECT filename FROM #{self.table_name} WHERE user_id = '#{user_id}' AND user_route_ID = #{user_route_id} AND user_photo_id = #{user_photo_id}").getvalue(0,0)
    File.delete("/web_server/user_photos/#{user_id}/#{user_route_id}/#{filename}")
    
    # Delete photo entry from DB
    Photolog.connection.execute("DELETE FROM #{self.table_name} WHERE user_id = '#{user_id}' AND user_route_ID = #{user_route_id} AND user_photo_id = #{user_photo_id}")
    
    return '1'
    
  end
  
  def check_pass(password, user_id)
    # If password provided by the querier is incorrect, reject query
    if password != date[0..3] + user_id.reverse + date[4..5]
      return nil
    else
      return Digest::SHA2.hexdigest(user_id)
    end
  end  
end
