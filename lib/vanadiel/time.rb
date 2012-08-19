# encoding: utf-8

require 'vanadiel/day'
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

    def firesday?;      @wday == Vanadiel::Day::FIRESDAY;      end
    def earthsday?;     @wday == Vanadiel::Day::EARTHSDAY;     end
    def watersday?;     @wday == Vanadiel::Day::WATERSDAY;     end
    def windsday?;      @wday == Vanadiel::Day::WINDSDAY;      end
    def iceday?;        @wday == Vanadiel::Day::ICEDAY;        end
    def lightningday?;  @wday == Vanadiel::Day::LIGHTNINGDAY;  end
    def lightsday?;     @wday == Vanadiel::Day::LIGHTSDAY;     end
    def darksday?;      @wday == Vanadiel::Day::DARKSDAY;      end

    # Format Vana'diel time according to the directives in the format string.
    # The directives begins with a percent (%) character. Any text not listed
    # as a directive will be passed through to the output string.
    #
    # The directive consists of a percent (%) character, zero or more flags,
    # optional minimum field width and a conversion specifier as follows.
    #
    #   %<flags><width><conversion>
    #
    # Flags:
    #   -  don't pad a numerical output.
    #   _  use spaces for padding.
    #   0  use zeros for padding.
    #   ^  upcase the result string.
    #   #  change case.
    #
    # The minimum field width specifies the minimum width.
    #
    # Format directives:
    #   Date (Year, Month, Day):
    #     %Y - Year with century (can be negative)
    #             -0001, 0000, 1995, 2009, 14292, etc.
    #     %C - year / 100 (round down.  20 in 2009)
    #     %y - year % 100 (00..99)
    #
    #     %m - Month of the year, zero-padded (01..12)
    #             %_m  blank-padded ( 1..12)
    #             %-m  no-padded (1..12)
    #
    #     %d - Day of the month, zero-padded (01..30)
    #             %-d  no-padded (1..30)
    #     %e - Day of the month, blank-padded ( 1..30)
    #
    #     %j - Day of the year (001..360)
    #
    #   Time (Hour, Minute, Second, Subsecond):
    #     %H - Hour of the day, 24-hour clock, zero-padded (00..23)
    #     %k - Hour of the day, 24-hour clock, blank-padded ( 0..23)
    #
    #     %M - Minute of the hour (00..59)
    #
    #     %S - Second of the minute (00..59)
    #
    #     %L - Millisecond of the second (000..999)
    #     %N - Fractional seconds digits, default is 6 digits (microsecond)
    #             %3N  millisecond (3 digits)
    #             %6N  microsecond (6 digits)
    #
    #   Weekday:
    #     %A - The full weekday name (``Firesday'')
    #             %^A  uppercased (``FIRESDAY'')
    #     %w - Day of the week (Firesday is 0, 0..7)
    #
    #   Seconds since the Epoch:
    #     %s - Number of seconds since 0001-01-01 00:00:00
    #
    #   Literal string:
    #     %n - Newline character (\n)
    #     %t - Tab character (\t)
    #     %% - Literal ``%'' character
    #
    #   Combination:
    #     %F - The ISO 8601 date format (%Y-%m-%d)
    #     %X - Same as %T
    #     %R - 24-hour time (%H:%M)
    #     %T - 24-hour time (%H:%M:%S)
    def strftime(format)
      source = { 'Y' => @year,  'C' => @year / 100, 'y' => @year % 100,
                 'm' => @month, 'd' => @mday, 'e' => @mday, 'j' => @yday,
                 'H' => @hour,  'k' => @hour, 'M' => @min,  'S' => @sec, 'L' => @usec, 'N' => @usec,
                 'A' => @wday,  'w' => @wday, 's' => @time.to_i,
                 'n' => "\n",   't' => "\t",  '%' => '%' }
      default_padding = { 'e' => ' ', 'k' => ' ', 'A' => ' ', 'n' => ' ', 't' => ' ', '%' => ' ' }
      default_padding.default = '0'
      default_width = { 'y' => 2, 'm' => 2, 'd' => 2, 'e' => 2, 'H' => 2, 'k' => 2, 'M' => 2, 'S' => 2,
                        'j' => 3, 'L' => 3,
                        'N' => 6 }
      default_width.default = 0

      format.gsub(/%([-_0^#]+)?(\d+)?([FXRT])/) {
        case $3
        when 'F'      then '%Y-%m-%d'
        when 'T', 'X' then '%H:%M:%S'
        when 'R'      then '%H:%M'
        end
      }.gsub(/%([-_0^#]+)?(\d+)?([YCymdejHkMSLNAawsnt%])/) {|s|
        flags = $1; width = $2.to_i; conversion = $3; upcase = false
        padding = default_padding[conversion]
        width = default_width[conversion] if width.zero?
        v = source[conversion]

        flags.each_char {|c|
          case c
          when '-' then padding = nil
          when '_' then padding = ' '
          when '0' then padding = '0'
          when '^', '#' then upcase = true
          end
        } if flags

        case conversion
        when 'L', 'N'
          if (width <= 6)
            v = v / (100000 / (10 ** (width - 1)))
          else
            v = v * (10 ** (width - 6))
          end
        when 'A'
          v = Vanadiel::Day::DAYNAMES[v]
        end

        v = v.to_s
        if width > 0 && padding && v.length < width
          v = (padding * (width - v.length)) + v
        end

        upcase ? v.upcase : v
      }
    end

    def to_i; @time.to_i; end
    def to_f; @time;      end

    def to_earth_time
      ::Time.at(self.class.vana_to_earth(@time) / ONE_SECOND)
    end

    def hash; @time.hash ^ self.class.hash; end

    def ==(other);   @time == other.to_f;      end
    def eql?(other); self.hash == other.hash; end

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
