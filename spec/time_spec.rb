# encoding: utf-8

require 'spec_helper'
require 'vanadiel/time'
require 'time'

describe Vanadiel::Time do
  it "should have a VERSION constant" do
    subject.class.const_get('VERSION').should_not be_empty
  end
end

describe Vanadiel::Time, '.earth_to_vana' do
  context 'with argument -91270800000000' do
    it 'should return 0' do
      Vanadiel::Time.earth_to_vana(-91270800000000).should == 0
    end
  end
end

describe Vanadiel::Time, '.vana_to_earth' do
  context 'with argument 0' do
    it 'should return -91270800000000' do
      Vanadiel::Time.vana_to_earth(0).should == -91270800000000
    end
  end
end

share_examples_for 'Vanadiel::Time with no argument' do
  before do
    @time_now = Time.local(2002, 1, 1, 12, 34, 56)
    Time.stub!(:now).and_return(@time_now)
  end

  it "should create current time object" do
    subject.to_earth_time.to_f.round(6).should == @time_now.to_f.round(6)
  end
end

shared_examples 'YMDHMS constructor' do |ctor|
  # A.D. 1967/02/10 00:00:00 JST
  # C.E. 0001/01/01 00:00:00
  context 'with arguments (1, 1, 1, 0, 0, 0)' do
    subject { Vanadiel::Time.send(ctor, 1, 1, 1, 0, 0, 0) }
    it 'should create Vana\'diel time "0001/01/01 00:00:00"' do
      subject.to_earth_time.should == Time.iso8601('1967-02-10T00:00:00+09:00')
    end
  end

  # A.D. 2002/01/01(Tue) 00:00:00 JST
  # C.E. 0886/01/01(Fir) 00:00:00
  context 'with arguments (886, 1, 1, 0, 0, 0)' do
    subject { Vanadiel::Time.send(ctor, 886, 1, 1, 0, 0, 0) }
    it 'should create Vana\'diel time "0886/01/01 00:00:00"' do
      subject.to_earth_time.should == Time.iso8601('2002-01-01T00:00:00+09:00')
    end
  end

  # A.D. 2047/10/22(Tue) 01:00:00 JST
  # C.E. 2047/10/22(Wat) 01:00:00
  context 'with arguments (2047, 10, 22, 1, 0, 0)' do
    subject { Vanadiel::Time.send(ctor, 2047, 10, 22, 1, 0, 0) }
    it 'should create Vana\'diel time "2047/10/22 01:00:00"' do
      subject.to_earth_time.should == Time.iso8601('2047-10-22T01:00:00+09:00')
    end
  end

  # A.D. 2047/10/21(Mon) 15:37:30 UTC
  # C.E. 2047/10/21(Win) 15:37:30
  context 'with arguments (2047, 10, 21, 15, 37, 30)' do
    subject { Vanadiel::Time.send(ctor, 2047, 10, 21, 15, 37, 30) }
    it 'should create Vana\'diel time "2047/10/21 15:37:30"' do
      subject.to_earth_time.should == Time.gm(2047, 10, 21, 15, 37, 30)
    end
  end

  context 'with arguments (1, 1, 1, 0, 0, 0, 0)' do
    subject { Vanadiel::Time.send(ctor, 1, 1, 1, 0, 0, 0, 0) }
    it 'should create Vana\'diel time "1/01/01 00:00:00"' do
      subject.to_f.should == 0
    end
  end

  context 'with arguments (1, 1, 1, 0, 0, 0, 999999)' do
    subject { Vanadiel::Time.send(ctor, 1, 1, 1, 0, 0, 0, 999999) }
    it 'should create Vana\'diel time "1/01/01 00:00:00.999999"' do
      subject.to_f.should == 999999
    end
  end
end

describe Vanadiel::Time, '.new' do
  include_examples 'YMDHMS constructor', :new

  context 'with no argument' do
    subject { Vanadiel::Time.new }
    it_should_behave_like 'Vanadiel::Time with no argument'
  end
end

describe Vanadiel::Time, '.now' do
  describe '.now' do
    subject { Vanadiel::Time.now }
    it_should_behave_like 'Vanadiel::Time with no argument'
  end
end

describe Vanadiel::Time, '.mktime' do
  include_examples 'YMDHMS constructor', :mktime

  context 'with no argument' do
    subject { Vanadiel::Time.new }
    it "should raise ArgumentError" do
      expect { Vanadiel::Time.mktime }.to raise_error(ArgumentError)
    end
  end
end

describe Vanadiel::Time, '.at' do
  before do
    @vana_time = Vanadiel::Time.mktime(886, 1, 1, 0, 0, 0)
    @earth_time = Time.now
  end

  context 'with argument Vanadiel::Time' do
    subject { Vanadiel::Time.at(@vana_time) }
    it "should create Vana'diel time with passed time" do
      subject.to_f.round(6).should == @vana_time.to_f.round(6)
    end
  end

  context 'with argument Time' do
    subject { Vanadiel::Time.at(@earth_time) }
    it "should create Vana'diel time with passed time" do
      subject.to_earth_time.to_f.round(6).should == @earth_time.to_f.round(6)
    end
  end

  context 'with argument Float' do
    subject { Vanadiel::Time.at(@vana_time.to_f) }
    it "should create Vana'diel time with passed time as Vana'diel time" do
      subject.to_f.round(6).should == @vana_time.to_f.round(6)
    end
  end

  context 'with argument "foo"' do
    it "should raise ArgumentError" do
      expect { Vanadiel::Time.at('foo') }.to raise_error(ArgumentError)
    end
  end
end

describe 'Vanadiel::Time properties' do
  share_examples_for "time object which has each part property" do
    its(:year)         { should == @year         }
    its(:month)        { should == @mon          }
    its(:mon)          { should == @mon          }
    its(:mday)         { should == @day          }
    its(:day)          { should == @day          }
    its(:hour)         { should == @hour         }
    its(:min)          { should == @min          }
    its(:sec)          { should == @sec          }
    its(:usec)         { should == @usec         }
    its(:wday)         { should == @wday         }
    its(:yday)         { should == @yday         }
    its(:moon_age)     { should == @moon_age     }
    its(:moon_age7)    { should == @moon_age7    }
    its(:time_of_moon) { should == @time_of_moon }
  end

  context 'with C.E. 887/04/21 12:34:56' do
    before do
      @year = 887;  @mon  = 4;    @day      = 21
      @hour = 12;   @min  = 34;   @sec      = 56; @usec      = 123456
      @wday = 6;    @yday = 111;  @moon_age = 7;  @moon_age7 = 5;     @time_of_moon = 131696123456
    end

    subject { Vanadiel::Time.new(@year, @mon, @day, @hour, @min, @sec, @usec) }

    it_should_behave_like "time object which has each part property"
  end
end

describe Vanadiel::Time, '#moon_percent' do
  patterns = [
    { 'vana_time' => Vanadiel::Time.new(   1,  1,  1), 'moon_age' =>  1, 'moon_age7' => 1, 'moon_percent' =>  19 },
    { 'vana_time' => Vanadiel::Time.new( 886,  1,  1), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>  10 },

    # 二十六夜 12%(Waning Crescent Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 18, 23, 59, 59, 999999), 'moon_age' => 11, 'moon_age7' => 7, 'moon_percent' =>  12 },
    # 新月 10%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 19), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>  10 },
    # 新月 10%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 19, 23, 59, 59, 999999), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>  10 },
    # 新月 7%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 20), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   7 },
    # 新月 5%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 21), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   5 },
    # 新月 2%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 22), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   2 },
    # 新月 2%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 22, 23, 59, 59, 999999), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   2 },
    # 新月 0%(New Moon)
    { 'vana_time' => Vanadiel::Time.new(1155, 12, 23), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   0 },

    { 'vana_time' => Vanadiel::Time.new(1156,  1,  2), 'moon_age' =>  1, 'moon_age7' => 1, 'moon_percent' =>  21 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1,  3), 'moon_age' =>  2, 'moon_age7' => 1, 'moon_percent' =>  24 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1,  9), 'moon_age' =>  2, 'moon_age7' => 1, 'moon_percent' =>  38 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 10), 'moon_age' =>  3, 'moon_age7' => 2, 'moon_percent' =>  40 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 16), 'moon_age' =>  3, 'moon_age7' => 2, 'moon_percent' =>  55 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 17), 'moon_age' =>  4, 'moon_age7' => 3, 'moon_percent' =>  57 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 23), 'moon_age' =>  4, 'moon_age7' => 3, 'moon_percent' =>  71 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 24), 'moon_age' =>  5, 'moon_age7' => 3, 'moon_percent' =>  74 },
    { 'vana_time' => Vanadiel::Time.new(1156,  1, 30), 'moon_age' =>  5, 'moon_age7' => 3, 'moon_percent' =>  88 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2,  1), 'moon_age' =>  6, 'moon_age7' => 4, 'moon_percent' =>  90 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2,  5), 'moon_age' =>  6, 'moon_age7' => 4, 'moon_percent' => 100 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2,  7), 'moon_age' =>  6, 'moon_age7' => 4, 'moon_percent' =>  95 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2,  8), 'moon_age' =>  7, 'moon_age7' => 5, 'moon_percent' =>  93 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 14), 'moon_age' =>  7, 'moon_age7' => 5, 'moon_percent' =>  79 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 15), 'moon_age' =>  8, 'moon_age7' => 5, 'moon_percent' =>  76 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 21), 'moon_age' =>  8, 'moon_age7' => 5, 'moon_percent' =>  62 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 22), 'moon_age' =>  9, 'moon_age7' => 6, 'moon_percent' =>  60 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 28), 'moon_age' =>  9, 'moon_age7' => 6, 'moon_percent' =>  45 },
    { 'vana_time' => Vanadiel::Time.new(1156,  2, 29), 'moon_age' => 10, 'moon_age7' => 7, 'moon_percent' =>  43 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3,  5), 'moon_age' => 10, 'moon_age7' => 7, 'moon_percent' =>  29 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3,  6), 'moon_age' => 11, 'moon_age7' => 7, 'moon_percent' =>  26 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3, 12), 'moon_age' => 11, 'moon_age7' => 7, 'moon_percent' =>  12 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3, 13), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>  10 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3, 17), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   0 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3, 19), 'moon_age' =>  0, 'moon_age7' => 0, 'moon_percent' =>   5 },
    { 'vana_time' => Vanadiel::Time.new(1156,  3, 20), 'moon_age' =>  1, 'moon_age7' => 1, 'moon_percent' =>   7 },
  ]

  patterns.each {|p|
    context "with C.E. #{p['vana_time'].strftime('%F %T.%N')}" do
      subject { p['vana_time'] }
      its(:moon_age)     { should == p['moon_age'] }
      its(:moon_age12)   { should == p['moon_age'] }
      its(:moon_age7)    { should == p['moon_age7'] }
      its(:moon_percent) { should == p['moon_percent'] }
    end
  }

  # 1155/12/18 00:00:00 二十六夜 12%(Waning Crescent Moon)
  # 1155/12/19 00:00:00 新月 10%(New Moon)
  # 1155/12/20 00:00:00 新月 7%(New Moon)
  # 1155/12/21 00:00:00 新月 5%(New Moon)
  # 1155/12/22 00:00:00 新月 2%(New Moon)
  # 1155/12/23 00:00:00 新月 0%(New Moon)
  # 1155/12/24 00:00:00 新月 2%(New Moon)
  # 1155/12/25 00:00:00 新月 5%(New Moon)
  # 1155/12/26 00:00:00 三日月 7%(Waxing Crescent Moon)
  # 1155/12/27 00:00:00 三日月 10%(Waxing Crescent Moon)
  # 1155/12/28 00:00:00 三日月 12%(Waxing Crescent Moon)
  # 1155/12/29 00:00:00 三日月 14%(Waxing Crescent Moon)
  # 1155/12/30 00:00:00 三日月 17%(Waxing Crescent Moon)
  # 1156/01/01 00:00:00 三日月 19%(Waxing Crescent Moon)
  # 1156/01/02 00:00:00 三日月 21%(Waxing Crescent Moon)
  # 1156/01/03 00:00:00 七日月 24%(Waxing Crescent Moon)
  # 1156/01/04 00:00:00 七日月 26%(Waxing Crescent Moon)
  # 1156/01/05 00:00:00 七日月 29%(Waxing Crescent Moon)
  # 1156/01/06 00:00:00 七日月 31%(Waxing Crescent Moon)
  # 1156/01/07 00:00:00 七日月 33%(Waxing Crescent Moon)
  # 1156/01/08 00:00:00 七日月 36%(Waxing Crescent Moon)
  # 1156/01/09 00:00:00 七日月 38%(Waxing Crescent Moon)
  # 1156/01/10 00:00:00 上弦の月 40%(First Quarter Moon)
  # 1156/01/11 00:00:00 上弦の月 43%(First Quarter Moon)
  # 1156/01/12 00:00:00 上弦の月 45%(First Quarter Moon)
  # 1156/01/13 00:00:00 上弦の月 48%(First Quarter Moon)
  # 1156/01/14 00:00:00 上弦の月 50%(First Quarter Moon)
  # 1156/01/15 00:00:00 上弦の月 52%(First Quarter Moon)
  # 1156/01/16 00:00:00 上弦の月 55%(First Quarter Moon)
  # 1156/01/17 00:00:00 十日夜 57%(Waxing Gibbous Moon)
  # 1156/01/18 00:00:00 十日夜 60%(Waxing Gibbous Moon)
  # 1156/01/19 00:00:00 十日夜 62%(Waxing Gibbous Moon)
  # 1156/01/20 00:00:00 十日夜 64%(Waxing Gibbous Moon)
  # 1156/01/21 00:00:00 十日夜 67%(Waxing Gibbous Moon)
  # 1156/01/22 00:00:00 十日夜 69%(Waxing Gibbous Moon)
  # 1156/01/23 00:00:00 十日夜 71%(Waxing Gibbous Moon)
  # 1156/01/24 00:00:00 十三夜 74%(Waxing Gibbous Moon)
  # 1156/01/25 00:00:00 十三夜 76%(Waxing Gibbous Moon)
  # 1156/01/26 00:00:00 十三夜 79%(Waxing Gibbous Moon)
  # 1156/01/27 00:00:00 十三夜 81%(Waxing Gibbous Moon)
  # 1156/01/28 00:00:00 十三夜 83%(Waxing Gibbous Moon)
  # 1156/01/29 00:00:00 十三夜 86%(Waxing Gibbous Moon)
  # 1156/01/30 00:00:00 十三夜 88%(Waxing Gibbous Moon)
  # 1156/02/01 00:00:00 満月 90%(Full Moon)
  # 1156/02/02 00:00:00 満月 93%(Full Moon)
  # 1156/02/03 00:00:00 満月 95%(Full Moon)
  # 1156/02/04 00:00:00 満月 98%(Full Moon)
  # 1156/02/05 00:00:00 満月 100%(Full Moon)
  # 1156/02/06 00:00:00 満月 98%(Full Moon)
  # 1156/02/07 00:00:00 満月 95%(Full Moon)
  # 1156/02/08 00:00:00 十六夜 93%(Waning Gibbous Moon)
  # 1156/02/09 00:00:00 十六夜 90%(Waning Gibbous Moon)
  # 1156/02/10 00:00:00 十六夜 88%(Waning Gibbous Moon)
  # 1156/02/11 00:00:00 十六夜 86%(Waning Gibbous Moon)
  # 1156/02/12 00:00:00 十六夜 83%(Waning Gibbous Moon)
  # 1156/02/13 00:00:00 十六夜 81%(Waning Gibbous Moon)
  # 1156/02/14 00:00:00 十六夜 79%(Waning Gibbous Moon)
  # 1156/02/15 00:00:00 居待月 76%(Waning Gibbous Moon)
  # 1156/02/16 00:00:00 居待月 74%(Waning Gibbous Moon)
  # 1156/02/17 00:00:00 居待月 71%(Waning Gibbous Moon)
  # 1156/02/18 00:00:00 居待月 69%(Waning Gibbous Moon)
  # 1156/02/19 00:00:00 居待月 67%(Waning Gibbous Moon)
  # 1156/02/20 00:00:00 居待月 64%(Waning Gibbous Moon)
  # 1156/02/21 00:00:00 居待月 62%(Waning Gibbous Moon)
  # 1156/02/22 00:00:00 下弦の月 60%(Last Quarter Moon)
  # 1156/02/23 00:00:00 下弦の月 57%(Last Quarter Moon)
  # 1156/02/24 00:00:00 下弦の月 55%(Last Quarter Moon)
  # 1156/02/25 00:00:00 下弦の月 52%(Last Quarter Moon)
  # 1156/02/26 00:00:00 下弦の月 50%(Last Quarter Moon)
  # 1156/02/27 00:00:00 下弦の月 48%(Last Quarter Moon)
  # 1156/02/28 00:00:00 下弦の月 45%(Last Quarter Moon)
  # 1156/02/29 00:00:00 二十日余月 43%(Waning Crescent Moon)
  # 1156/02/30 00:00:00 二十日余月 40%(Waning Crescent Moon)
  # 1156/03/01 00:00:00 二十日余月 38%(Waning Crescent Moon)
  # 1156/03/02 00:00:00 二十日余月 36%(Waning Crescent Moon)
  # 1156/03/03 00:00:00 二十日余月 33%(Waning Crescent Moon)
  # 1156/03/04 00:00:00 二十日余月 31%(Waning Crescent Moon)
  # 1156/03/05 00:00:00 二十日余月 29%(Waning Crescent Moon)
  # 1156/03/06 00:00:00 二十六夜 26%(Waning Crescent Moon)
  # 1156/03/07 00:00:00 二十六夜 24%(Waning Crescent Moon)
  # 1156/03/08 00:00:00 二十六夜 21%(Waning Crescent Moon)
  # 1156/03/09 00:00:00 二十六夜 19%(Waning Crescent Moon)
  # 1156/03/10 00:00:00 二十六夜 17%(Waning Crescent Moon)
  # 1156/03/11 00:00:00 二十六夜 14%(Waning Crescent Moon)
  # 1156/03/12 00:00:00 二十六夜 12%(Waning Crescent Moon)
  # 1156/03/13 00:00:00 新月 10%(New Moon)
  # 1156/03/14 00:00:00 新月 7%(New Moon)
  # 1156/03/15 00:00:00 新月 5%(New Moon)
  # 1156/03/16 00:00:00 新月 2%(New Moon)
  # 1156/03/17 00:00:00 新月 0%(New Moon)
  # 1156/03/18 00:00:00 新月 2%(New Moon)
  # 1156/03/19 00:00:00 新月 5%(New Moon)
  # 1156/03/20 00:00:00 三日月 7%(Waxing Crescent Moon)
  # 1156/03/21 00:00:00 三日月 10%(Waxing Crescent Moon)
  # 1156/03/22 00:00:00 三日月 12%(Waxing Crescent Moon)
  # 1156/03/23 00:00:00 三日月 14%(Waxing Crescent Moon)
  # 1156/03/24 00:00:00 三日月 17%(Waxing Crescent Moon)
  # 1156/03/25 00:00:00 三日月 19%(Waxing Crescent Moon)
  # 1156/03/26 00:00:00 三日月 21%(Waxing Crescent Moon)
  # 1156/03/27 00:00:00 七日月 24%(Waxing Crescent Moon)
  # 1156/03/28 00:00:00 七日月 26%(Waxing Crescent Moon)
  # 1156/03/29 00:00:00 七日月 29%(Waxing Crescent Moon)
  # 1156/03/30 00:00:00 七日月 31%(Waxing Crescent Moon)
  # 1156/04/01 00:00:00 七日月 33%(Waxing Crescent Moon)
  # 1156/04/02 00:00:00 七日月 36%(Waxing Crescent Moon)
  # 1156/04/03 00:00:00 七日月 38%(Waxing Crescent Moon)
  # 1156/04/04 00:00:00 上弦の月 40%(First Quarter Moon)
end

shared_context 'Vanadiel::Time with arguments(2047, 10, 21, 15, 37, 30, 123456)' do
  let(:vana_time) { Vanadiel::Time.new(2047, 10, 21, 15, 37, 30, 123456) }
end

describe Vanadiel::Time, ' weekday methods' do
  context 'when C.E. 1000-01-01' do
    subject { Vanadiel::Time.new(1000, 1, 1) }
    it { should be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-02' do
    subject { Vanadiel::Time.new(1000, 1, 2) }
    it { should_not be_firesday }
    it { should be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-03' do
    subject { Vanadiel::Time.new(1000, 1, 3) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-04' do
    subject { Vanadiel::Time.new(1000, 1, 4) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-05' do
    subject { Vanadiel::Time.new(1000, 1, 5) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-06' do
    subject { Vanadiel::Time.new(1000, 1, 6) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should be_lightningday }
    it { should_not be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-07' do
    subject { Vanadiel::Time.new(1000, 1, 7) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should be_lightsday }
    it { should_not be_darksday }
  end

  context 'when C.E. 1000-01-08' do
    subject { Vanadiel::Time.new(1000, 1, 8) }
    it { should_not be_firesday }
    it { should_not be_earthsday }
    it { should_not be_watersday }
    it { should_not be_windsday }
    it { should_not be_iceday }
    it { should_not be_lightningday }
    it { should_not be_lightsday }
    it { should be_darksday }
  end
end

describe Vanadiel::Time, '#to_i' do
  include_context 'Vanadiel::Time with arguments(2047, 10, 21, 15, 37, 30, 123456)'
  subject { vana_time.to_i }
  it { should be_kind_of Integer }
  it { should === 63663896250123456 }
end

describe Vanadiel::Time, '#to_f' do
  include_context 'Vanadiel::Time with arguments(2047, 10, 21, 15, 37, 30, 123456)'
  subject { vana_time.to_f }
  it { should be_kind_of Float }
  it { should === 63663896250123456.0 }
end

describe Vanadiel::Time, '#strftime' do
  context 'with 0886-03-04 05:06:07' do
    let(:vana_time) { Vanadiel::Time.new(886, 3, 4, 5, 6, 7, 80900) }

    patterns = {
      '%Y'   => '886',    '%-Y'  => '886',   '%_Y'  => '886',    '%0Y'  => '886',
      '%6Y'  => '000886', '%-6Y' => '886',   '%_6Y' => '   886', '%06Y' => '000886', '%01Y' => '886',

      '%C'   => '8',      '%-C'  => '8',     '%_C'  => '8',      '%0C'  => '8',
      '%6C'  => '000008', '%-6C' => '8',     '%_6C' => '     8', '%06C' => '000008', '%01C' => '8',

      '%y'   => '86',     '%-y'  => '86',    '%_y'  => '86',     '%0y'  => '86',
      '%6y'  => '000086', '%-6y' => '86',    '%_6y' => '    86', '%06y' => '000086', '%01y' => '86',

      '%m'   => '03',     '%-m'  => '3',     '%_m'  => ' 3',     '%0m'  => '03',
      '%6m'  => '000003', '%-6m' => '3',     '%_6m' => '     3', '%06m' => '000003', '%01m' => '3',

      '%d'   => '04',     '%-d'  => '4',     '%_d'  => ' 4',     '%0d'  => '04',
      '%6d'  => '000004', '%-6d' => '4',     '%_6d' => '     4', '%06d' => '000004', '%01d' => '4',

      '%e'   => ' 4',     '%-e'  => '4',     '%_e'  => ' 4',     '%0e'  => '04',
      '%6e'  => '     4', '%-6e' => '4',     '%_6e' => '     4', '%06e' => '000004', '%01e' => '4',

      '%j'   => '064',    '%-j'  => '64',    '%_j'  => ' 64',    '%0j'  => '064',
      '%6j'  => '000064', '%-6j' => '64',    '%_6j' => '    64', '%06j' => '000064', '%01j' => '64',

      '%H'   => '05',     '%-H'  => '5',     '%_H'  => ' 5',     '%0H'  => '05',
      '%6H'  => '000005', '%-6H' => '5',     '%_6H' => '     5', '%06H' => '000005', '%01H' => '5',

      '%k'   => ' 5',     '%-k'  => '5',     '%_k'  => ' 5',     '%0k'  => '05',
      '%6k'  => '     5', '%-6k' => '5',     '%_6k' => '     5', '%06k' => '000005', '%01k' => '5',

      '%M'   => '06',     '%-M'  => '6',     '%_M'  => ' 6',     '%0M'  => '06',
      '%6M'  => '000006', '%-6M' => '6',     '%_6M' => '     6', '%06M' => '000006', '%01M' => '6',

      '%S'   => '07',     '%-S'  => '7',     '%_S'  => ' 7',     '%0S'  => '07',
      '%6S'  => '000007', '%-6S' => '7',     '%_6S' => '     7', '%06S' => '000007', '%01S' => '7',

      '%L'   => '080',    '%-L'  => '80',    '%_L'  => ' 80',    '%0L'  => '080',
      '%6L'  => '080900', '%-6L' => '80900', '%_6L' => ' 80900', '%06L' => '080900', '%01L' => '0',

      '%N'   => '080900', '%-N'  => '80900', '%_N'  => ' 80900', '%0N'  => '080900',
      '%6N'  => '080900', '%-6N' => '80900', '%_6N' => ' 80900', '%06N' => '080900', '%01N' => '0',
      '%1N'  => '0',      '%2N'  => '08',    '%3N'  => '080',    '%4N'  => '0809',   '%5N'  => '08090',
      '%7N'  => '0809000', '%8N' => '08090000', '%9N' => '080900000', '%12N' => '080900000000',

      '%A'    => 'Darksday',   '%-A'    => 'Darksday', '%_A'      => 'Darksday',   '%0A'   => 'Darksday',
      '%10A'  => '  Darksday', '%-10A'  => 'Darksday', '%_10A'    => '  Darksday', '%010A' => '00Darksday', '%01A' => 'Darksday',
      '%^A'   => 'DARKSDAY',   '%-^A'   => 'DARKSDAY', '%_^A'     => 'DARKSDAY',
      '%^10A' => '  DARKSDAY', '%_^10A' => '  DARKSDAY', '%0^10A' => '00DARKSDAY',
      '%#A'   => 'DARKSDAY',   '%-#A'   => 'DARKSDAY', '%_#A'     => 'DARKSDAY',
      '%#10A' => '  DARKSDAY', '%_#10A' => '  DARKSDAY', '%0#10A' => '00DARKSDAY',

      '%w'   => '7',      '%-w'  => '7',     '%_w'  => '7',      '%0w'  => '7',
      '%6w'  => '000007', '%-6w' => '7',     '%_6w' => '     7', '%06w' => '000007', '%01w' => '7',

      '%s'   => '27532501567080900',    '%-s'   => '27532501567080900', '%_s'   => '27532501567080900',    '%0s'   => '27532501567080900',
      '%20s' => '00027532501567080900', '%-20s' => '27532501567080900', '%_20s' => '   27532501567080900', '%020s' => '00027532501567080900', '%01s' => '27532501567080900',

      '%n'  => "\n",   '%-n'  => "\n", '%_n'  => "\n",   '%0n'  => "\n",
      '%3n' => "  \n", '%-3n' => "\n", '%_3n' => "  \n", '%03n' => "00\n", '%01n' => "\n",

      '%t'  => "\t",   '%-t'  => "\t", '%_t'  => "\t",   '%0t'  => "\t",
      '%3t' => "  \t", '%-3t' => "\t", '%_3t' => "  \t", '%03t' => "00\t", '%01t' => "\t",

      '%%'  => '%',    '%-%'  => '%',  '%_%'  => '%',    '%0%'  => '%',
      '%3%' => '  %',  '%-3%' => '%',  '%_3%' => '  %',  '%03%' => '00%',  '%01%' => '%',

      '%F'   => '886-03-04', '%-F'   => '886-03-04', '%_F'   => '886-03-04', '%0F'   => '886-03-04',
      '%12F' => '886-03-04', '%-12F' => '886-03-04', '%_12F' => '886-03-04', '%012F' => '886-03-04', '%01F' => '886-03-04',
      '%^F'  => '886-03-04', '%#F'   => '886-03-04', '%_^F'  => '886-03-04', '%0#F'  => '886-03-04',

      '%T'   => '05:06:07', '%-T'    => '05:06:07', '%_T'    => '05:06:07', '%0T'    => '05:06:07',
      '%12T' => '05:06:07', '%-12T'  => '05:06:07', '%_12T'  => '05:06:07', '%012T'  => '05:06:07', '%01T'  => '05:06:07',
      '%^T'  => '05:06:07', '%#T'    => '05:06:07', '%_^T'   => '05:06:07', '%0#T'   => '05:06:07',

      '%X'   => '05:06:07', '%-X'    => '05:06:07', '%_X'    => '05:06:07', '%0X'    => '05:06:07',
      '%12X' => '05:06:07', '%-12X'  => '05:06:07', '%_12X'  => '05:06:07', '%012X'  => '05:06:07', '%01X'  => '05:06:07',
      '%^X'  => '05:06:07', '%#X'    => '05:06:07', '%_^X'   => '05:06:07', '%0#X'   => '05:06:07',

      '%R'   => '05:06', '%-R'       => '05:06', '%_R'       => '05:06', '%0R'       => '05:06',
      '%12R' => '05:06', '%-12R'     => '05:06', '%_12R'     => '05:06', '%012R'     => '05:06', '%01R'     => '05:06',
      '%^R'  => '05:06', '%#R'       => '05:06', '%_^R'      => '05:06', '%0#R'      => '05:06',

      "Vana'diel %F %T"             => "Vana'diel 886-03-04 05:06:07",
      "Vana'diel %Y/%m/%d %H:%M:%S" => "Vana'diel 886/03/04 05:06:07",
    }

    patterns.each {|conversion, expect|
      describe conversion do
        subject { vana_time.strftime(conversion) }
        it { should == expect }
      end
    }
  end
end

describe Vanadiel::Time, '#==' do
  context 'with same value different object' do
    let(:other) { described_class.new(2047, 10, 21) }
    subject     { described_class.new(2047, 10, 21) }
    it 'should be true' do
      should == other
    end
  end
end

describe Vanadiel::Time, '#eql?' do
  context 'with same value different object' do
    let(:other) { described_class.new(2047, 10, 21) }
    subject     { described_class.new(2047, 10, 21) }
    it 'should be true' do
      should eql other
    end
  end
end

describe Vanadiel::Time, '#+' do
  context 'with 10.123456' do
    subject { described_class.new(2047, 10, 21) + 10.123456 }
    it 'should add 10.123456sec and returns that value as a new time' do
      should == described_class.new(2047, 10, 21, 0, 0, 10, 123456)
    end
  end

  context 'with -10.123456' do
    subject { described_class.new(2047, 10, 21) + -10.123456 }
    it 'should subtract 10.123456sec and returns that value as a new time' do
      should == described_class.new(2047, 10, 20, 23, 59, 49, 876544)
    end
  end
end

describe Vanadiel::Time, '#-' do
  context 'with 10.123456' do
    subject { described_class.new(2047, 10, 21) - 10.123456 }
    it 'should subtract 10.123456sec and returns that value as a new time' do
      should == described_class.new(2047, 10, 20, 23, 59, 49, 876544)
    end
  end

  context 'with -10.123456' do
    subject { described_class.new(2047, 10, 21) - -10.123456 }
    it 'should add 10.123456sec and returns that value as a new time' do
      should == described_class.new(2047, 10, 21, 0, 0, 10, 123456)
    end
  end

  context "with Vana'diel time" do
    before do
      @sec = 10.123456
      @vt = described_class.new(2047, 10, 21)
    end
    subject { @vt - (@vt - @sec) }
    it 'should return difference sec' do
      should == @sec
    end
    it 'should return Float' do
      (@vt - (@vt - 10)).should be_kind_of Float
    end
  end
end

describe Vanadiel::Time, '#<=>' do
  context 'with greater time' do
    subject { described_class.new(2047, 10, 21) <=> described_class.new(2047, 10, 22) }
    it { should == -1 }
  end

  context 'with less time' do
    subject { described_class.new(2047, 10, 21) <=> described_class.new(2047, 10, 20) }
    it { should == 1 }
  end

  context 'with same time' do
    subject { described_class.new(2047, 10, 21) <=> described_class.new(2047, 10, 21) }
    it { should == 0 }
  end
end
