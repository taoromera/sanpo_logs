class RouteController < ApplicationController
 
  def up_route
    # params: user_id, password, date, user_route_id, points, title
    log = Routelog.new
    status = log.up_route(params)
    render :json => @json
  end
  
end
