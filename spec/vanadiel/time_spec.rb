# encoding: utf-8

require 'spec_helper'
require 'vanadiel/time'
require 'time'

describe Vanadiel::Time do
  describe '.earth_to_vana' do
    context 'with argument -91270800000000' do
      it 'should return 0' do
        Vanadiel::Time.earth_to_vana(-91270800000000).should == 0
      end
    end
  end

  describe '.vana_to_earth' do
    context 'with argument 0' do
      it 'should return -91270800000000' do
        Vanadiel::Time.vana_to_earth(0).should == -91270800000000
      end
    end
  end

  describe '.mktime' do
    # A.D. 1967/02/10 00:00:00 JST
    # C.E. 0001/01/01 00:00:00
    context 'with argument (1, 1, 1, 0, 0, 0)' do
      subject { Vanadiel::Time.mktime(1, 1, 1, 0, 0, 0) }
      it 'should return earth time "1967/02/10 00:00:00 +0900"' do
        subject.to_earth_time.should == Time.iso8601('1967-02-10T00:00:00+09:00')
      end
    end

    # A.D. 2002/01/01(Tue) 00:00:00 JST
    # C.E. 0886/01/01(Fir) 00:00:00
    context 'with argument (886, 1, 1, 0, 0, 0)' do
      subject { Vanadiel::Time.mktime(886, 1, 1, 0, 0, 0) }
      it 'should return earth time "2002/01/01 00:00:00 +0900"' do
        subject.to_earth_time.should == Time.iso8601('2002-01-01T00:00:00+09:00')
      end
    end

    # A.D. 2047/10/22(Tue) 01:00:00 JST
    # C.E. 2047/10/22(Wat) 01:00:00
    context 'with argument (2047, 10, 22, 1, 0, 0)' do
      subject { Vanadiel::Time.mktime(2047, 10, 22, 1, 0, 0) }
      it 'should return earth time "2047/10/22 01:00:00 +0900"' do
        subject.to_earth_time.should == Time.iso8601('2047-10-22T01:00:00+09:00')
      end
    end

    # A.D. 2047/10/21(Mon) 15:37:30 UTC
    # C.E. 2047/10/21(Win) 15:37:30
    context 'with argument (2047, 10, 21, 15, 37, 30)' do
      subject { Vanadiel::Time.mktime(2047, 10, 21, 15, 37, 30) }
      it 'should return earth time "2047/10/21 15:37:30 +0000"' do
        subject.to_earth_time.should == Time.gm(2047, 10, 21, 15, 37, 30)
      end
    end
  end
end
