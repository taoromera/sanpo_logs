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
    
    Routelog.connection.execute("INSERT INTO sanpo_routes(id,user_route_id, user_id, start_time, end_time, start_lat, start_lng, end_lat, end_lng, geom, public, length, tracking_times) VALUES (DEFAULT,#{user_route_id}, '#{user_id}', '#{start_time}', '#{end_time}', '#{start_lat}', '#{start_lng}', '#{end_lat}', '#{end_lng}', #{geom}, '1', ST_Length(ST_Transform(#{geom},26986)), '#{timestamps.join(',')}')")
    
    return []
  end
  
end
