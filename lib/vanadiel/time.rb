# encoding: utf-8

require 'vanadiel/day'
require 'vanadiel/moon'

module Vanadiel
  # Vanadiel::Time is an abstraction of Vana'diel dates and times from Final Fantasy XI.
  # Time is stored internally as the number of microseconds since C.E. 0001-01-01 00:00:00.
  #
  # Vana'diel time spec:
  #
  #     One year   = 12 months = 360 days
  #     One month  = 30 days
  #     One day    = 24 hours
  #     One hour   = 60 minutes
  #     One minute = 60 seconds
  #     One second = 0.04 seconds of the earth's (1/25th of a second)
  #
  #     Vana'diel second         = 0.04 earth seconds (1/25th of a second)
  #     Vana'diel minute         = 2.4 earth seconds
  #     Vana'diel hour           = 2 minutes 24 earth seconds
  #     Vana'diel day            = 57 minutes 36 earth seconds
  #     Vana'diel week           = 7 hours 40 minutes 48 earth seconds
  #     Vana'diel calendar month = 1 day 4 hours 48 earth minutes
  #     Vana'diel lunar month    = 3 days 14 hours 24 earth minutes
  #     Vana'diel year           = 14 days 9 hours 36 earth minutes
  #
  #     Each full lunar cycle lasts for 84 Vana'diel days.
  #     Vana'diel has 12 distinct moon phases.
  #     Japanese client expresses moon phases by 12 kinds of texts. (percentage is not displayed in Japanese client)
  #     Non-Japanese client expresses moon phases by 7 kinds of texts and percentage.
  #
  # C.E. = Crystal Era
  #
  #     A.D. -91270800 => 1967/02/10 00:00:00 +0900
  #     C.E. 0         => 0001/01/01 00:00:00
  #
  #     A.D. 2002/01/01(Tue) 00:00:00 JST
  #     C.E. 0886/01/01(Fir) 00:00:00
  #
  #     A.D. 2047/10/22(Tue) 01:00:00 JST
  #     C.E. 2047/10/22(Wat) 01:00:00
  #
  #     A.D. 2047/10/21(Mon) 15:37:30 UTC
  #     C.E. 2047/10/21(Win) 15:37:30
  class Time
    include Comparable

    # vanadiel-time version
    VERSION = "0.2.1"

    ONE_SECOND = 1000000
    ONE_MINUTE = 60  * ONE_SECOND
    ONE_HOUR   = 60  * ONE_MINUTE
    ONE_DAY    = 24  * ONE_HOUR
    ONE_WEEK   = 8   * ONE_DAY
    ONE_MONTH  = 30  * ONE_DAY
    ONE_YEAR   = 360 * ONE_DAY

    VANA_TIME_SCALE = 25  # Vana'diel time goes 25 times faster than the Earth
    VANA_BASE_YEAR  = 886
    VANA_BASE_TIME  = (VANA_BASE_YEAR * ONE_YEAR) / VANA_TIME_SCALE
    EARTH_BASE_TIME = 1009810800 * ONE_SECOND  # 2002/01/01 00:00:00.000 JST
    DIFF_TIME       = VANA_BASE_TIME - EARTH_BASE_TIME
    MOON_CYCLE_DAYS = 84  # Vana'diel moon cycle lasts 84 days

    # @return [Bignum] the value of the time as microseconds since C.E. 0001-01-01 00:00:00
    attr_reader :time

    # @return [Fixnum] the year for time
    attr_reader :year

    # @return [Fixnum] the month of the year (1..12) for time
    attr_reader  :month

    # @return [Fixnum] the month of the year (1..12) for time
    alias_method :mon, :month

    # @return [Fixnum] the day of the month (1..30) for time
    attr_reader  :mday
    alias_method :day, :mday

    # @return [Fixnum] the hour of the day (0..23) for time
    attr_reader  :hour

    # @return [Fixnum] the minute of the hour (0..59) for time
    attr_reader  :min

    # @return [Fixnum] the second of the minute (0..59) for time
    attr_reader  :sec

    # @return [Fixnum] just the number of microseconds (0..999999) for time
    attr_reader  :usec

    # @return [Fixnum] an integer representing the day of the week, 0..7, with Firesday == 0
    attr_reader  :wday

    # @return [Fixnum] an integer representing the day of the year (1..360)
    attr_reader  :yday

    # @return [Fixnum] an integer representing the moon age (0..11), for Japanese service
    attr_reader  :moon_age
    alias_method :moon_age12, :moon_age

    # @return [Fixnum] an integer representing the moon age (0..7), for Non-Japanese service
    attr_reader  :moon_age7

    # @return [Fixnum] an integer representing the moon phase percentage (0..100), for Non-Japanese service
    attr_reader  :moon_percent

    # @return [Fixnum] the number of microseconds of the moon
    attr_reader  :time_of_moon

    # It is initialized to the current time if no argument.
    # If one or more arguments specified, the time is initialized to the specified time.
    #
    # @overload new()
    #   It is initialized to the current time if no argument.
    # @overload new(year, mon = 1, day = 1, hour = 0, min = 0, sec = 0, usec = 0)
    #   If one or more arguments specified, the time is initialized to the specified time.
    #   @param [Integer] year the year part (1..n)
    #   @param [Integer] mon the month part (1..12)
    #   @param [Integer] day the day of month part (1..30)
    #   @param [Integer] hour the hour part (0..23)
    #   @param [Integer] min the minute part (0..59)
    #   @param [Integer] sec the second part (0..59)
    #   @param [Integer] usec the microsecond part (0..999999)
    def initialize(*args)
      self.time = args.empty? ? self.class.earth_to_vana(::Time.now.to_f * ONE_SECOND) : self.class.ymdhms_to_usec(*args)
    end

    # Synonym for Vanadiel::Time.new. Returns a new time object initialized to the current time.
    #
    # @return [Vanadiel::Time] the time object initialized to the current time.
    def self.now
      self.new
    end

    # Same as Vanadiel::Time.new, but the year is required.
    #
    # @return [Vanadiel::Time] the time object initialized to the specified time.
    def self.mktime(year, *rest_part)
      args = [year, *rest_part]
      self.new(*args)
    end

    # Creates a new time object with the value given by time.
    #
    # @overload at(time)
    #   @param [::Time, Vanadiel::Time] time the time object
    #   @return [Vanadiel::Time] the time object initialized to the specified time.
    # @overload at(seconds, usec = 0)
    #   @param [Integer, Float] sec seconds from C.E. 0001-01-01 00:00:00
    #   @param [Integer] usec the microseconds
    #   @return [Vanadiel::Time] the time object initialized to the specified time.
    def self.at(time, usec = 0)
      obj = self.new
      if time.is_a? ::Time
        obj.time = self.earth_to_vana(time.to_f * ONE_SECOND)
      elsif time.is_a?(Vanadiel::Time)
        obj.time = time.time
      elsif time.is_a?(Integer) || time.is_a?(Float)
        obj.time = ((time * ONE_SECOND) + usec).to_i
      else
        raise ArgumentError, 'invalid argument'
      end
      obj
    end

    # Converts microseconds as Vana'diel time to microseconds as the Earth time from the Epoch.
    #
    # @param [Integer] vana_time microseconds as Vana'diel time
    # @return [Integer] microseconds as the Earth time
    def self.vana_to_earth(vana_time)
       (((vana_time + ONE_YEAR) / VANA_TIME_SCALE) - DIFF_TIME)
    end

    # Converts microseconds as the Earth time to microseconds as Vana'diel time from the Epoch.
    #
    # @param [Integer] earth_time microseconds as the Earth time
    # @return [Integer] microseconds as Vana'diel time
    def self.earth_to_vana(earth_time)
      (earth_time + DIFF_TIME) * VANA_TIME_SCALE - ONE_YEAR
    end

    # Returns true if time represents Firesday.
    #
    # @return [Boolean] true if Firesday
    def firesday?;      @wday == Vanadiel::Day::FIRESDAY;      end

    # Returns true if time represents Earthsday.
    #
    # @return [Boolean] true if Earthsday
    def earthsday?;     @wday == Vanadiel::Day::EARTHSDAY;     end

    # Returns true if time represents Watersday.
    #
    # @return [Boolean] true if Watersday
    def watersday?;     @wday == Vanadiel::Day::WATERSDAY;     end

    # Returns true if time represents Windsday.
    #
    # @return [Boolean] true if Windsday
    def windsday?;      @wday == Vanadiel::Day::WINDSDAY;      end

    # Returns true if time represents Iceday.
    #
    # @return [Boolean] true if Iceday
    def iceday?;        @wday == Vanadiel::Day::ICEDAY;        end

    # Returns true if time represents Lightningday.
    #
    # @return [Boolean] true if Lightningday
    def lightningday?;  @wday == Vanadiel::Day::LIGHTNINGDAY;  end

    # Returns true if time represents Lightsday.
    #
    # @return [Boolean] true if Lightsday
    def lightsday?;     @wday == Vanadiel::Day::LIGHTSDAY;     end

    # Returns true if time represents Darksday.
    #
    # @return [Boolean] true if Darksday
    def darksday?;      @wday == Vanadiel::Day::DARKSDAY;      end

    # Format Vana'diel time according to the directives in the format string.
    # The directives begins with a percent (%) character. Any text not listed
    # as a directive will be passed through to the output string.
    #
    # The directive consists of a percent (%) character, zero or more flags,
    # optional minimum field width and a conversion specifier as follows.
    #
    #     %<flags><width><conversion>
    #
    # Flags:
    #
    #     -  don't pad a numerical output.
    #     _  use spaces for padding.
    #     0  use zeros for padding.
    #     ^  upcase the result string.
    #     #  change case.
    #
    # The minimum field width specifies the minimum width.
    #
    # Format directives:
    #
    #     Date (Year, Month, Day):
    #       %Y - Year with century (can be negative)
    #               -0001, 0000, 1995, 2009, 14292, etc.
    #       %C - year / 100 (round down.  20 in 2009)
    #       %y - year % 100 (00..99)
    #
    #       %m - Month of the year, zero-padded (01..12)
    #               %_m  blank-padded ( 1..12)
    #               %-m  no-padded (1..12)
    #
    #       %d - Day of the month, zero-padded (01..30)
    #               %-d  no-padded (1..30)
    #       %e - Day of the month, blank-padded ( 1..30)
    #
    #       %j - Day of the year (001..360)
    #
    #     Time (Hour, Minute, Second, Subsecond):
    #       %H - Hour of the day, 24-hour clock, zero-padded (00..23)
    #       %k - Hour of the day, 24-hour clock, blank-padded ( 0..23)
    #
    #       %M - Minute of the hour (00..59)
    #
    #       %S - Second of the minute (00..59)
    #
    #       %L - Millisecond of the second (000..999)
    #       %N - Fractional seconds digits, default is 6 digits (microsecond)
    #               %3N  millisecond (3 digits)
    #               %6N  microsecond (6 digits)
    #
    #     Weekday:
    #       %A - The full weekday name (``Firesday'')
    #               %^A  uppercased (``FIRESDAY'')
    #       %w - Day of the week (Firesday is 0, 0..7)
    #
    #     Seconds since the Epoch:
    #       %s - Number of seconds since 0001-01-01 00:00:00
    #
    #     Literal string:
    #       %n - Newline character (\n)
    #       %t - Tab character (\t)
    #       %% - Literal ``%'' character
    #
    #     Combination:
    #       %F - The ISO 8601 date format (%Y-%m-%d)
    #       %X - Same as %T
    #       %R - 24-hour time (%H:%M)
    #       %T - 24-hour time (%H:%M:%S)
    #
    # @param [String] format the format string
    # @return [String] formatted string
    def strftime(format)
      source = { 'Y' => @year,  'C' => @year / 100, 'y' => @year % 100,
                 'm' => @month, 'd' => @mday, 'e' => @mday, 'j' => @yday,
                 'H' => @hour,  'k' => @hour, 'M' => @min,  'S' => @sec, 'L' => @usec, 'N' => @usec,
                 'A' => @wday,  'w' => @wday, 's' => @time,
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

    # Adds some number of seconds (possibly fractional) to time and returns that value as a new time.
    #
    # @param [Integer, Float] sec seconds
    # @return [Vanadiel::Time] new time
    def +(sec)
      self.class.at((@time + (sec * ONE_SECOND)) / ONE_SECOND)
    end

    # Returns a new time that represents the difference between two times,
    # or subtracts the given number of seconds in numeric from time.
    #
    # @overload -(time)
    #   Returns a new time that represents the difference between two times.
    #   @param [::Time, Vanadiel::Time] other_time the other time object
    #   @return [Float] seconds that represents the difference
    # @overload -(seconds)
    #   Subtracts the given number of seconds in numeric from time.
    #   @param [Integer, Float] sec seconds
    #   @return [Vanadiel::Time] new time
    def -(time)
      if time.is_a? ::Time
        (@time.to_f - self.class.earth_to_vana(time.to_f * ONE_SECOND)) / ONE_SECOND
      elsif time.is_a?(Vanadiel::Time)
        (@time.to_f - time.time) / ONE_SECOND
      elsif time.is_a?(Integer) || time.is_a?(Float)
        self.class.at((@time / ONE_SECOND) - time)
      else
        raise ArgumentError, 'invalid argument'
      end
    end

    # Compares time with other time.
    #
    # @param [Vanadiel::Time] other_time the other time
    # @return [-1] if the time is earlier than the other time.
    # @return [0] if the time is same as the other time.
    # @return [1] if the time is later than the other time.
    # @return [nil] if it cannot compare.
    def <=>(other_time)
      @time <=> other_time.time
    end

    # Returns the value of time as a floating point number of seconds since C.E. 0001-01-01 00:00:00.
    #
    # @return [Float] seconds
    def to_i
      @time / ONE_SECOND
    end

    # Returns the value of time as an integer number of seconds since C.E. 0001-01-01 00:00:00.
    #
    # @return [Integer] seconds
    def to_f
      @time.to_f / ONE_SECOND
    end

    # Returns a string representing time. Equivalent to calling #strftime with
    # a format string of "%Y-%m-%d %H:%M:%S".
    #
    # @return [String] the string representing time
    def to_s
      self.strftime('%Y-%m-%d %H:%M:%S')
    end

    # Returns the value of time as the Earth time object.
    #
    # @return [::Time] the Earth time object
    def to_earth_time
      ::Time.at(self.class.vana_to_earth(@time) / ONE_SECOND)
    end

    # Returns a hash code for this time object.
    #
    # @return [Fixnum] the hash code
    def hash; @time.hash ^ self.class.hash; end

    # Returns true if time and other time are both Vanadiel::Time objects with the same time.
    #
    # @return [Boolean] true if same
    def eql?(other); self.hash == other.hash; end

    # Manually sets the time and recompute all fields.
    #
    # @param [Integer] time an integer number of microseconds
    # @note This accessor is used internally.
    def time=(time)
      @time = time
      compute_fields
    end

    def marshal_dump
      @time
    end

    def marshal_load(obj)
      self.time = obj
    end

    # Converts to the value of time as an integer number of microseconds since C.E. 0001-01-01 00:00:00.
    #
    # @param [Integer] year the year part (1..n)
    # @param [Integer] mon the month part (1..12)
    # @param [Integer] day the day of month part (1..30)
    # @param [Integer] hour the hour part (0..23)
    # @param [Integer] min the minute part (0..59)
    # @param [Integer] sec the second part (0..59)
    # @param [Integer] usec the microsecond part (0..999999)
    # @return [Integer] microseconds as Vana'diel time
    def self.ymdhms_to_usec(year, mon = 1, day = 1, hour = 0, min = 0, sec = 0, usec = 0)
      raise ArgumentError, 'year out of range' if year < 0
      raise ArgumentError, 'mon out of range'  if mon  < 1 || mon > 12
      raise ArgumentError, 'day out of range'  if day  < 1 || day > 30
      raise ArgumentError, 'hour out of range' if hour < 0 || hour > 23
      raise ArgumentError, 'min out of range'  if min  < 0 || min > 59
      raise ArgumentError, 'sec out of range'  if sec  < 0 || sec > 59
      raise ArgumentError, 'usec out of range' if usec < 0 || usec > 999999
      ((year - 1) * ONE_YEAR) + ((mon - 1) * ONE_MONTH) + ((day - 1) * ONE_DAY) + (hour * ONE_HOUR) + (min * ONE_MINUTE) + (sec * ONE_SECOND) + usec
    end

    private

    # Computes fields by its value of time.
    def compute_fields
      @year         = (@time / ONE_YEAR).floor + 1
      @month        = (@time % ONE_YEAR / ONE_MONTH).floor + 1
      @mday         = (@time % ONE_MONTH / ONE_DAY).floor + 1
      @hour         = (@time % ONE_DAY / ONE_HOUR).floor
      @min          = (@time % ONE_HOUR / ONE_MINUTE).floor
      @sec          = (@time % ONE_MINUTE / ONE_SECOND).floor
      @usec         = (@time % ONE_SECOND).floor

      @wday         = (@time % ONE_WEEK / ONE_DAY).floor
      @yday         = ((@month - 1) * 30) + @mday

      # MOON_BASE_TIME  = 0 - (ONE_DAY * 12) # Start of New moon (10%)
      #
      # moon_time     = @time - MOON_BASE_TIME
      # @moon_age     = (moon_time / ONE_DAY / 7 % (MAX_MOON_AGE + 1)).floor
      # @time_of_moon = ((moon_time / ONE_DAY % 7) * ONE_DAY).floor
      #               + (@hour * ONE_HOUR)
      #               + (@min * ONE_MINUTE)
      #               + (@sec * ONE_SECOND)
      #               + (@usec)

      # C.E. 0001/01/01 00:00:00 => WXC 19%
      # C.E. 0886/01/01 00:00:00 => NM  10%
      #
      # 0% NM   7% WXC  40% FQM  57% WXG   90% FM  93% WNG  60% LQM  43% WNC  10% NM
      # 2% NM  10% WXC  43% FQM  60% WXG   93% FM  90% WNG  57% LQM  40% WNC   7% NM
      # 5% NM  12% WXC  45% FQM  62% WXG   95% FM  88% WNG  55% LQM  38% WNC   5% NM
      #        14% WXC  48% FQM  64% WXG   98% FM  86% WNG  52% LQM  36% WNC   2% NM
      #        17% WXC  50% FQM  67% WXG  100% FM  83% WNG  50% LQM  33% WNC
      #        19% WXC  52% FQM  69% WXG   98% FM  81% WNG  48% LQM  31% WNC
      #        21% WXC  55% FQM  71% WXG   95% FM  79% WNG  45% LQM  29% WNC
      #        24% WXC           74% WXG           76% WNG           26% WNC
      #        26% WXC           76% WXG           74% WNG           24% WNC
      #        29% WXC           79% WXG           71% WNG           21% WNC
      #        31% WXC           81% WXG           69% WNG           19% WNC
      #        33% WXC           83% WXG           67% WNG           17% WNC
      #        36% WXC           86% WXG           64% WNG           14% WNC
      #        38% WXC           88% WXG           62% WNG           12% WNC
      days = (@time / ONE_DAY).floor
      @moon_percent = (((days + 8) % MOON_CYCLE_DAYS) * (200.0 / MOON_CYCLE_DAYS)).round
      @moon_percent = 200 - @moon_percent if @moon_percent > 100

      @moon_age     = ((days + 12) / 7) % 12
      @moon_age7    = case @moon_age
                      when 0      then 0
                      when 1, 2   then 1
                      when 3      then 2
                      when 4, 5   then 3
                      when 6      then 4
                      when 7, 8   then 5
                      when 9      then 6
                      when 10, 11 then 7
                      end
      @time_of_moon = (((days + 12) % 7) * ONE_DAY) + (@hour * ONE_HOUR) + (@min * ONE_MINUTE) + (@sec * ONE_SECOND) + @usec
    end
  end
end
