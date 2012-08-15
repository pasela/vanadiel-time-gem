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

shared_examples_for 'YMDHMS constructor' do
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
  let(:ctor) { :new }
  it_should_behave_like 'YMDHMS constructor'

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
  let(:ctor) { :mktime }
  it_should_behave_like 'YMDHMS constructor'

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

# describe Vanadiel::Time, '#to_s' do
#   include_context 'Vanadiel::Time with arguments(2047, 10, 21, 15, 37, 30, 123456)'
#   subject { vana_time.to_s }
#   it { should be_kind_of String }
#   it { should === '2047-10-21 15:37:30' }
# end
