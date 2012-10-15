class Routelog < ActiveRecord::Base

  self.table_name = "sanpo_routes"
  
  def up_route(params)
  
    user_id = params[:user_id]
    password = params[:password]
    date = params[:date]
    user_route_id = params[:user_route_id]
    points = params[:points]
    title = params[:title]
  
    # If password provided by the querier is incorrect, reject query
    if password != date[0..3] + user_id.reverse + date[4..5]
      return "Error: password incorrect"
    end
    
    user_id = Digest::SHA2.hexdigest(params[:user_id])
    
    # Split points into coords and timestamps
    arr = points.split(',')
    coords = []
    timestamps = []
    (0..arr.length/3-1).each do |idx|
      coords.push "#{arr[idx*3+1]} #{arr[idx*3]}"
      timestamps.push arr[idx*3+2]
    end

    # Insert data into DB
    start_time = timestamps[0]
    end_time = timestamps[-1]
    start_lat = arr[0]
    start_lng = arr[1]
    end_lat = arr[-3]
    end_lng = arr[-2]
    
    geom = "ST_GeometryFromText('MULTILINESTRING((#{coords.join(',')}))', 4326)"
    
    Routelog.connection.execute("INSERT INTO sanpo_routes(id,user_route_id, user_id, start_time, end_time, start_lat, start_lng, end_lat, end_lng, geom, public, length, tracking_times, title) VALUES (DEFAULT,#{user_route_id}, '#{user_id}', '#{start_time}', '#{end_time}', '#{start_lat}', '#{start_lng}', '#{end_lat}', '#{end_lng}', #{geom}, '1', ST_Length(ST_Transform(#{geom},26986)), '#{timestamps.join(',')}', '#{title}')")
    
    return {:result => '1'}
  end

  def view_log(user_id, route_id)
    user_id = Digest::SHA2.hexdigest(user_id)
    res = Routelog.connection.execute("SELECT start_time, end_time, start_lat, start_lng, end_lat, end_lng, ST_AsText(geom), length, title, end_time-start_time FROM sanpo_routes WHERE user_id = '#{user_id}' AND user_route_id = #{route_id}")
    start_time = res.getvalue(0,0)
    end_time = res.getvalue(0,1)
    start_lat = res.getvalue(0,2)
    start_lng = res.getvalue(0,3)
    end_lat = res.getvalue(0,4)
    end_lng = res.getvalue(0,5)
    geom = res.getvalue(0,6)
    length = res.getvalue(0,7)
    title = res.getvalue(0,8)
    walk_time = res.getvalue(0,9)

    # Parse raw text into several multilinestring objects
    geom = [geom].flatten.map! {|i| factory.parse_wkt(i)}    
    
    # Convert "route" into one multi_line_string object
    path = factory.multi_line_string geom
    
    # Parse route_final to make a RGEO object
    geom = RGeo::GeoJSON.encode(path)

    lat, lon, shoot_time, memo, geo_tag, filename = Routelog.connection.execute("SELECT lat, lng, shoot_time, memo, geo_tag, filename FROM sanpo_photos WHERE user_id = '#{user_id}' AND user_route_id = #{route_id}").values.transpose

    photos = []
    if !lat.nil?
      lat.each_with_index do |la,idx|
        photos.push [{:lat => la, :lon => lon[idx], :shoot_time => shoot_time[idx], :memo => memo[idx], :geo_tag => geo_tag[idx], :url => "sanpo.mobi/user_photos/#{user_id}/#{route_id}/#{filename[idx]}"}]
      end
      photos.flatten!
    end
    
    return {:result => '1', :start_time => start_time, :end_time => end_time, :start_lat => start_lat, :start_lng => start_lng, :end_lat => end_lat, :end_lng => end_lng, :geom => geom, :length => length, :title => title, :walk_time => walk_time, :photos => photos}
  end
  
  def factory
    @@factory ||= RGeo::Geographic.spherical_factory(:srid => 4326)
  end

end
