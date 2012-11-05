class Routelog < ActiveRecord::Base

  self.table_name = "sanpo_routes"
  
  def make_public(params)

    user_id = params[:user_id]
    password = params[:password]
    date = params[:date]
    user_route_id = params[:user_route_id]
  
    user_id = check_pass(password, user_id, date)
    if user_id.nil?
      return "Error: password incorrect"
    end

    Routelog.connection.execute("UPDATE sanpo_routes SET public = '1' WHERE user_id = '#{user_id}' AND user_route_id = #{user_route_id}")

    return {:result => '1'}
  end


  def up_route(params)
  
    user_id = params[:user_id]
    password = params[:password]
    date = params[:date]
    user_route_id = params[:user_route_id]
    points = params[:points]
    title = params[:title]
  
    user_id = check_pass(password, user_id, date)
    if user_id.nil?
      return "Error: password incorrect"
    end
    
    # Split points into coords and timestamps
    arr = points.split(',')
    coords = []
    timestamps = []
    (0..arr.length/3-1).each do |idx|
      # Filter out incorrect GPS measurement points (-180, -180) 
      if arr[idx*3+1].to_i != -180 && arr[idx*3].to_i != -180
        coords.push "#{arr[idx*3+1]} #{arr[idx*3]}"
        timestamps.push arr[idx*3+2]
      end
    end

    # Insert data into DB
    start_time = timestamps[0]
    end_time = timestamps[-1]
    start_lat = coords[0].split(' ')[0]
    start_lng = coords[0].split(' ')[1]
    end_lat = coords[-1].split(' ')[0]
    end_lng = coords[-1].split(' ')[1]
    
    geom = "ST_GeometryFromText('MULTILINESTRING((#{coords.join(',')}))', 4326)"
    
    # Check if route is already in the DB. If so, overwrite it.
    id = Routelog.connection.execute("SELECT id FROM sanpo_routes WHERE user_route_id = #{user_route_id} AND user_id = '#{user_id}'").values
    id.flatten!
   
    if id.empty?
      Routelog.connection.execute("INSERT INTO sanpo_routes(id,user_route_id, user_id, start_time, end_time, start_lat, start_lng, end_lat, end_lng, geom, public, length, tracking_times, title) VALUES (DEFAULT,#{user_route_id}, '#{user_id}', '#{start_time}', '#{end_time}', '#{start_lat}', '#{start_lng}', '#{end_lat}', '#{end_lng}', #{geom}, '0', ST_Length(ST_Transform(#{geom},26986)), '#{timestamps.join(',')}', '#{title}')")
    else
      Routelog.connection.execute("UPDATE sanpo_routes SET start_time = '#{start_time}', end_time = '#{end_time}', start_lat = #{start_lat}, start_lng = #{start_lng}, end_lat = #{end_lat}, end_lng = #{end_lng}, geom = #{geom}, public = '0', length = ST_Length(ST_Transform(#{geom},26986)), tracking_times = '#{timestamps.join(',')}', title = '#{title}' WHERE id = #{id[0]}")
    end

    return {:result => '1', :start_time => arr[2]}
  end

  def view_log(user_id, route_id)
    user_id = Digest::SHA2.hexdigest(user_id)
    res = Routelog.connection.execute("SELECT start_time, end_time, start_lat, start_lng, end_lat, end_lng, ST_AsText(geom), length, title, end_time-start_time, public FROM sanpo_routes WHERE user_id = '#{user_id}' AND user_route_id = #{route_id}")
    
    # If route is not public, return
    if (res.getvalue(0,10) == 'f')
      return {:result => '2'}
    end

    start_time = res.getvalue(0,0)
    end_time = res.getvalue(0,1)
    start_lat = res.getvalue(0,2)
    start_lng = res.getvalue(0,3)
    end_lat = res.getvalue(0,4)
    end_lng = res.getvalue(0,5)
    geom = res.getvalue(0,6)
    length = res.getvalue(0,7).to_f.round(0)/1000.0
    title = res.getvalue(0,8)
    walk_time = res.getvalue(0,9)

    # Parse raw text into several multilinestring objects
    geom = [geom].flatten.map! {|i| factory.parse_wkt(i)}    
    
    # Convert "route" into one multi_line_string object
    path = factory.multi_line_string geom
    
    # Parse route_final to make a RGEO object
    geom = RGeo::GeoJSON.encode(path)

    # Get photos for this route
    lat, lon, shoot_time, memo, geo_tag, filename = Routelog.connection.execute("SELECT lat, lng, shoot_time, memo, geo_tag, filename FROM sanpo_photos WHERE user_id = '#{user_id}' AND user_route_id = #{route_id} ORDER BY id ASC").values.transpose

    photos = []
    if !lat.nil?
      lat.each_with_index do |la,idx|
        photos.push [{:lat => la, :lon => lon[idx], :shoot_time => shoot_time[idx], :memo => memo[idx], :geo_tag => geo_tag[idx], :url => "sanpo.mobi/user_photos/#{user_id}/#{route_id}/#{filename[idx]}"}]
      end
      photos.flatten!
    end
    
    return {:result => '1', :start_time => start_time, :end_time => end_time, :start_lat => start_lat, :start_lng => start_lng, :end_lat => end_lat, :end_lng => end_lng, :geom => geom, :walk_distance => length, :title => title, :walk_time => walk_time, :photos => photos}
  end
  
  def del_route(params)
    user_id = params[:user_id]
    password = params[:password]
    date = params[:date]
    user_route_id = params[:user_route_id]
  
    user_id = check_pass(password, user_id, date)
    if user_id.nil?
      return("Error: password incorrect")
    end
    
    # Delete route log from DB
    Routelog.connection.execute("DELETE FROM #{Routelog.table_name} WHERE user_id = '#{user_id}' AND user_route_ID = #{user_route_id}")

    # Delete photo files
    FileUtils.rm_rf "/web_server/user_photos/#{user_id}/#{user_route_id}"

    # Delete photo entries from DB
    Photolog.connection.execute("DELETE FROM #{Photolog.table_name} WHERE user_id = '#{user_id}' AND user_route_ID = #{user_route_id}")

    return {:status => '1'}
  end
  
  def factory
    @@factory ||= RGeo::Geographic.spherical_factory(:srid => 4326)
  end
  
  def check_pass(password, user_id, date)
    # If password provided by the querier is incorrect, reject query
    if password != date[0..3] + user_id.reverse + date[4..5]
      return nil
    else
      return Digest::SHA2.hexdigest(user_id)
    end
  end  

end
