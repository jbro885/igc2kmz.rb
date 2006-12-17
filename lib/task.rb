require "coord"
require "lib"

class Task

  class Point < Coord

    attr_reader :name

    def initialize(lat, lon, alt, name)
      super(lat, lon, alt)
      @name = name
    end

    def intersect?(fix0, fix1)
      false
    end

  end

  class Circle < Point

    DEFAULT_RADIUS = nil 

    def initialize(lat, lon, alt, name, radius)
      super(lat, lon, alt, name)
      @radius = radius
    end

    def radius
      @radius || self.class.const_get("DEFAULT_RADIUS")
    end

    def intersect?(fix0, fix1)
      radius < distance_to(fix0) and distance_to(fix1) <= radius ? fix1 : nil
    end

  end

  class Turnpoint < Circle

    DEFAULT_RADIUS = 400

  end

  class StartCircle < Circle

    def initialize(lat, lon, alt, name, radius, start_time)
      super(lat, lon, alt, name, radius)
      @start_time = start_time
    end

  end

  class TakeOff < StartCircle

    DEFAULT_RADIUS = 1000

    def intersect?(fix0, fix1)
      distance_to(fix0) <= radius and @start_time <= fix0.time ? fix0 : false
    end

  end

  class StartOfSpeedSection < StartCircle

    def intersect?(fix0, fix1)
      @start_time <= fix0.time and super and fix0
    end

  end

  class EndOfSpeedSection < Circle
  end

  class GoalCircle < Circle

    DEFAULT_RADIUS = 400

  end

  class GoalLine < Point

    attr_reader :length
    attr_reader :axis

    def initialize(lat, lon, alt, name, length, axis)
      super(lat, lon, alt, name)
      @length = length
      @axis = axis
      @left = destination_at(@axis - Math::PI / 2.0, @length / 2.0)
      @right = destination_at(@axis + Math::PI / 2.0, @length / 2.0)
    end

    def intersect?(fix0, fix1)
      n1 = (fix1.lon - fix0.lon) * (@left.lat - fix0.lat) - (fix1.lat - fix0.lat) * (@left.lon - fix0.lon)
      return nil if n1.zero?
      d = (fix1.lat - fix0.lat) * (@right.lon - @left.lon) - (fix1.lon - fix0.lon) * (@right.lat - @left.lat)
      return nil if d.zero?
      return nil unless (0.0..1.0).include?(n1 / d)
      n2 = (@right.lon - @left.lon) * (@left.lat - fix0.lat) - (@right.lat - @left.lat) * (@left.lon - fix0.lon)
      return nil if n2.zero?
      (0.0..1.0).include?(n2 / d) ? fix1 : nil
    end

  end

  attr_reader :competition_name
  attr_reader :number
  attr_reader :course

  def initialize(competition_name, number, course)
    @competition_name = competition_name
    @number = number
    @course = course
  end

end
