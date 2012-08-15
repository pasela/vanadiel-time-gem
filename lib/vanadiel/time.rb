# encoding: utf-8

require 'vanadiel/week'
require 'vanadiel/moon'

# A.D. -91270800 => 1967/02/10 00:00:00 +0900
# C.E. 0         => 0001/01/01 00:00:00
#
# A.D. 2002/01/01(Tue) 00:00:00 JST
# C.E. 0886/01/01(Fir) 00:00:00
#
# A.D. 2047/10/22(Tue) 01:00:00 JST
# C.E. 2047/10/22(Wat) 01:00:00
#
# A.D. 2047/10/21(Mon) 15:37:30 UTC
# C.E. 2047/10/21(Win) 15:37:30
module Vanadiel
  class Time
    # Convenient constants for time calculation
    ONE_SECOND = 1000000.0
    ONE_MINUTE = 60  * ONE_SECOND
    ONE_HOUR   = 60  * ONE_MINUTE
    ONE_DAY    = 24  * ONE_HOUR
    ONE_WEEK   = 8   * ONE_DAY
    ONE_MONTH  = 30  * ONE_DAY
    ONE_YEAR   = 360 * ONE_DAY

    # Max values
    MAX_MDAY     = 30   # 1-origin
    MAX_MONTH    = 12   # 1-origin
    MAX_WDAY     = 7    # 0-origin
    MAX_YDAY     = 360  # 1-origin
    MAX_MOON_AGE = 11   # 0-origin

    VANA_TIME_SCALE = 25
    VANA_BASE_YEAR  = 886
    VANA_BASE_TIME  = (VANA_BASE_YEAR * ONE_YEAR) / VANA_TIME_SCALE
    EARTH_BASE_TIME = 1009810800 * ONE_SECOND  #=> 2002/01/01 00:00:00.000 JST
    DIFF_TIME       = VANA_BASE_TIME - EARTH_BASE_TIME
    MOON_BASE_TIME  = 0 - (ONE_DAY * 12) #=> New moon

    attr_reader :year, :month, :mday, :hour, :min, :sec, :usec
    alias_method :mon, :month
    alias_method :day, :mday
    attr_reader :wday         # Days since Fire
    attr_reader :yday         # Days since 1/1
    attr_reader :moon_age     # Moon age
    attr_reader :time_of_moon # Time after the moon

    # Create current Vana'diel time
    def initialize(*args)
      self.time = args.empty? ? self.class.earth_to_vana(::Time.now.to_f * ONE_SECOND) : self.class.ymdhms_to_time(*args)
    end

    # Create current Vana'diel time
    def self.now
      self.new
    end

    # Same as .new() but year is required
    def self.mktime(*args)
      raise ArgumentError, 'wrong number arguments' if args.empty?
      self.new(*args)
    end

    # Create specified Vana'diel time
    def self.at(time)
      obj = self.new
      if time.is_a? ::Time
        obj.time = self.earth_to_vana(time.to_f * ONE_SECOND)
      elsif time.is_a?(Vanadiel::Time) || time.is_a?(Integer) || time.is_a?(Float)
        obj.time = time.to_f
      else
        raise ArgumentError, 'invalid argument'
      end
      obj
    end

    # Vana'diel time(usec) to Earth time(UNIX usec)
    def self.vana_to_earth(vana_time)
       earth = (((vana_time + ONE_YEAR) / VANA_TIME_SCALE) - DIFF_TIME)
    end

    # Earth time(UNIX usec) to Vana'diel time(usec)
    def self.earth_to_vana(earth_time)
      (earth_time + DIFF_TIME) * VANA_TIME_SCALE - ONE_YEAR
    end

    def to_i
      @time.to_i
    end

    def to_f
      @time
    end

    def to_earth_time
      ::Time.at(self.class.vana_to_earth(@time) / ONE_SECOND)
    end

    def time=(time)
      @time = time
      compute_fields
    end

    def self.ymdhms_to_time(year, mon = 1, day = 1, hour = 0, min = 0, sec = 0, usec = 0)
      raise ArgumentError, 'year out of range' if year < 0
      raise ArgumentError, 'mon out of range'  if mon  < 1 || mon > MAX_MONTH
      raise ArgumentError, 'day out of range'  if day  < 1 || day > MAX_MDAY
      raise ArgumentError, 'hour out of range' if hour < 0 || hour > 23
      raise ArgumentError, 'min out of range'  if min  < 0 || min > 59
      raise ArgumentError, 'sec out of range'  if sec  < 0 || sec > 59
      raise ArgumentError, 'usec out of range' if usec < 0 || usec > 999999
      ((year - 1) * ONE_YEAR) + ((mon - 1) * ONE_MONTH) + ((day - 1) * ONE_DAY) + (hour * ONE_HOUR) + (min * ONE_MINUTE) + (sec * ONE_SECOND) + usec
    end

    private

    def compute_fields
      @year         = (@time / ONE_YEAR).floor + 1
      @month        = (@time % ONE_YEAR / ONE_MONTH).floor + 1
      @mday         = (@time % ONE_MONTH / ONE_DAY).floor + 1
      @hour         = (@time % ONE_DAY / ONE_HOUR).floor
      @min          = (@time % ONE_HOUR / ONE_MINUTE).floor
      @sec          = (@time % ONE_MINUTE / ONE_SECOND).floor
      @usec         = (@time % ONE_SECOND).floor

      @wday         = (@time % ONE_WEEK / ONE_DAY).floor
      @yday         = (@month * 30) + @mday - 1

      moon_time     = @time - MOON_BASE_TIME
      @moon_age     = (moon_time / ONE_DAY / 7 % (MAX_MOON_AGE + 1)).floor
      @time_of_moon = ((moon_time / ONE_DAY % 7) * ONE_DAY).floor
                    + (@hour * ONE_HOUR)
                    + (@min * ONE_MINUTE)
                    + (@sec * ONE_SECOND)
                    + (@usec)
    end
  end
end
