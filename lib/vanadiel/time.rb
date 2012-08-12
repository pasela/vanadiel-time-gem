# encoding: utf-8

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
    # Weekdays
    FIRE      = 0
    EARTH     = 1
    WATER     = 2
    WIND      = 3
    ICE       = 4
    LIGHTNING = 5
    LIGHT     = 6
    DARK      = 7

    # Moon age
    NEW_MOON           = 0  # 新月
    CRESCENT_MOON      = 1  # 三日月
    WAXING_CRESCENT1   = 1  # 三日月
    SIX_AGE_MOON       = 2  # 七日月
    WAXING_CRESCENT2   = 2  # 七日月
    FIRST_QUARTER      = 3  # 上弦の月
    NINE_AGE_MOON      = 4  # 十日夜
    WAXING_GIBBOUS1    = 4  # 十日夜
    GIBBOUS_MOON       = 5  # 十三夜
    WAXING_GIBBOUS2    = 5  # 十三夜
    FULL_MOON          = 6  # 満月
    FIFTEEN_AGE_MOON   = 7  # 十六夜
    WANING_GIBBOUS1    = 7  # 十六夜
    DISSEMINATING_MOON = 8  # 居待月
    WANING_GIBBOUS2    = 8  # 居待月
    LAST_QUARTER       = 9  # 下弦の月
    TWENTY_AGE_MOON    = 10 # 二十日余月
    WANING_CRESCENT1   = 10 # 二十日余月
    BALSAMIC_MOON      = 11 # 二十六夜
    WANING_CRESCENT2   = 11 # 二十六夜

    # Convenient constants for time calculation
    ONE_SECOND = 1000000.0
    ONE_MINUTE = 60  * ONE_SECOND
    ONE_HOUR   = 60  * ONE_MINUTE
    ONE_DAY    = 24  * ONE_HOUR
    ONE_WEEK   = 8   * ONE_DAY
    ONE_MONTH  = 30  * ONE_DAY
    ONE_YEAR   = 360 * ONE_DAY

    VANA_TIME_SCALE = 25
    VANA_BASE_YEAR  = 886
    VANA_BASE_TIME  = (VANA_BASE_YEAR * ONE_YEAR) / VANA_TIME_SCALE
    EARTH_BASE_TIME = 1009810800 * ONE_SECOND  #=> 2002/01/01 00:00:00.000 JST
    DIFF_TIME       = VANA_BASE_TIME - EARTH_BASE_TIME
    MOON_BASE_TIME  = 0 - (ONE_DAY * 12) #=> New moon

    def initialize(time = nil)
      time = ::Time.now if time.nil?

      if time.is_a? ::Time
        @time = self.class.earth_to_vana(time.to_f * ONE_SECOND)
      elsif time.is_a?(Vanadiel::Time) || time.is_a?(Integer) || time.is_a?(Float)
        @time = time.to_f
      else
        raise ArgumentError, 'Invalid argument'
      end
    end

    # Make current Vana'diel time
    def self.now
      self.new
    end

    # Make Vana'diel time
    def self.mktime(year, mon = 1, day = 1, hour = 0, min = 0, sec = 0)
      time = ((year - 1) * ONE_YEAR) + ((mon - 1) * ONE_MONTH) + ((day - 1) * ONE_DAY) + (hour * ONE_HOUR) + (min * ONE_MINUTE) + (sec * ONE_SECOND)
      self.new(time)
      # earth = self.vana_to_earth(time) / ONE_SECOND
      # #t, u = earth.to_s.split('.')
      # t = earth.floor
      # u = (earth - t) * ONE_SECOND
      # self.new(::Time.at(t, u))
    end

    # Vana'diel time(usec) to Earth time(UNIX usec)
    def self.vana_to_earth(vana_time)
       earth = (((vana_time + ONE_YEAR) / VANA_TIME_SCALE) - DIFF_TIME)
    end

    # Earth time(UNIX usec) to Vana'diel time(usec)
    def self.earth_to_vana(earth_time)
      (earth_time + DIFF_TIME) * VANA_TIME_SCALE - ONE_YEAR
    end

    def to_f
      @time
    end

    def to_earth_time
      ::Time.at(self.class.vana_to_earth(@time) / ONE_SECOND)
    end
  end
end
