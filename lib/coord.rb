########
#  This class is used to represent points in the map
#  it can be initialized with 2 floats long, lat
#  or with one string as "long,lat"
#######
class Coord

  def initialize(*args)
    if args.size == 2
      @point = Map.create_point(args[0], args[1])
    elsif args.size == 1
      if args[0].nil?
        @invalid = true
        return
      else
        param_ll = args[0].split(',').map(&:to_f)
        @point = Map.create_point(param_ll[0], param_ll[1])
      end
    end
    @invalid = false
  end
  def invalid?
    @invalid
  end
  def move(distance_x, distance_y)
    Coord.new(@point.x + distance_x, @point.y + distance_y)
  end

  def to_s
    "#{@point.x}, #{@point.y}"
  end
  def to_inverted_s
    "#{@point.y}, #{@point.x}"
  end

  def x
    @point.x
  end
  def y
    @point.y
  end
  def method_missing(m, *args, &block)
    @point.send(m, *args)
  end
end
