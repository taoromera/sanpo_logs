############
#  This is the class for a box like object on the map.
#  It can be initialized with a central point and the size of the square around it
#  or as 4 coordinates, long, lat, long, lat of the south-west, north-east points
############
class Box
  attr_reader :sw, :ne

  def initialize(*args)
    if (args.size == 2)
      point = args[0]
      side_length = args[1]
      box_r = side_length.to_f / 2
      @sw = point.move(-box_r, -box_r)
      @ne = point.move( box_r,  box_r)
    elsif (args.size == 4)
      @sw = Coord.new(args[0], args[1])
      @ne = Coord.new(args[2], args[3])
    end
  end
  def to_s
    "#{@sw.x} #{@sw.y}, #{@ne.x} #{@ne.y}"
  end
end


