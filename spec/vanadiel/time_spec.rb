# encoding: utf-8

require 'spec_helper'
require 'vanadiel/time'
require 'time'

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
    describe '#year'         do it { subject.year.should         == @year         } end
    describe '#month'        do it { subject.month.should        == @mon          } end
    describe '#mon'          do it { subject.mon.should          == @mon          } end
    describe '#mday'         do it { subject.mday.should         == @day          } end
    describe '#day'          do it { subject.day.should          == @day          } end
    describe '#hour'         do it { subject.hour.should         == @hour         } end
    describe '#min'          do it { subject.min.should          == @min          } end
    describe '#sec'          do it { subject.sec.should          == @sec          } end
    describe '#usec'         do it { subject.usec.should         == @usec         } end
    describe '#wday'         do it { subject.wday.should         == @wday         } end
    describe '#yday'         do it { subject.yday.should         == @yday         } end
    describe '#moon_age'     do it { subject.moon_age.should     == @moon_age     } end
    describe '#time_of_moon' do it { subject.time_of_moon.should == @time_of_moon } end
  end

  context 'with C.E. 887/04/21 12:34:56' do
    before do
      @year = 887;  @mon  = 4;    @day      = 21
      @hour = 12;   @min  = 34;   @sec      = 56; @usec         = 123456
      @wday = 6;    @yday = 140;  @moon_age = 7;  @time_of_moon = 131696123457
    end

    subject { Vanadiel::Time.new(@year, @mon, @day, @hour, @min, @sec, @usec) }

    it_should_behave_like "time object which has each part property"
  end
end

shared_context 'Vanadiel::Time with arguments(2047, 10, 21, 15, 37, 30, 123456)' do
  let(:vana_time) { Vanadiel::Time.new(2047, 10, 21, 15, 37, 30, 123456) }
end

describe Vanadiel::Time, '#fire? with 1000-01-01' do
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

      '%j'   => '093',    '%-j'  => '93',    '%_j'  => ' 93',    '%0j'  => '093',
      '%6j'  => '000093', '%-6j' => '93',    '%_6j' => '    93', '%06j' => '000093', '%01j' => '93',

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
