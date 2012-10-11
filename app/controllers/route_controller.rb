class RouteController < ApplicationController
 
  def up_route
    # params: user_id, password, date, user_route_id, points, title
    log = Routelog.new
    status = log.up_route(params)
    render :json => status
  end

  def view_log
    log = Routelog.new
    status = log.up_route(params[:user_id], params[:route_id])
    render :json => status
  end
 
  
end
