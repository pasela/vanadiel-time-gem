# encoding: utf-8

require 'spec_helper'
require 'vanadiel/time'

describe Vanadiel::Time, ' compare methods' do
  let(:earlier_time) { described_class.new(2047, 10, 20) }
  let(:base_time)    { described_class.new(2047, 10, 21) }
  let(:later_time)   { described_class.new(2047, 10, 22) }

  # ==
  context '== same value different object' do
    let(:other) { described_class.new(2047, 10, 21) }
    subject     { described_class.new(2047, 10, 21) }
    it { subject.==(other).should be_truthy }
  end
  context '== different values' do
    let(:other) { described_class.new(2047, 10, 21) }
    subject     { described_class.new(2047, 10, 22) }
    it { subject.==(other).should be_falsey }
  end

  # <
  context '< later(greater) time' do
    it { base_time.<(later_time).should be_truthy }
  end
  context '< earlier(less) time' do
    it { base_time.<(earlier_time).should be_falsey }
  end
  context '< same time' do
    it { base_time.<(base_time).should be_falsey }
  end

  # <=
  context '<= later(greater) time' do
    it { base_time.<=(later_time).should be_truthy }
  end
  context '<= earlier(less) time' do
    it { base_time.<=(earlier_time).should be_falsey }
  end
  context '<= same time' do
    it { base_time.<=(base_time).should be_truthy }
  end

  # >
  context '> later(greater) time' do
    it { base_time.>(later_time).should be_falsey }
  end
  context '> earlier(less) time' do
    it { base_time.>(earlier_time).should be_truthy }
  end
  context '> same time' do
    it { base_time.>(base_time).should be_falsey }
  end

  # >=
  context '>= later(greater) time' do
    it { base_time.>=(later_time).should be_falsey }
  end
  context '>= earlier(less) time' do
    it { base_time.>=(earlier_time).should be_truthy }
  end
  context '>= same time' do
    it { base_time.>=(base_time).should be_truthy }
  end

  # between?
  context 'between? later(greater) time and later(greater) time' do
    it { base_time.between?(later_time, later_time).should be_falsey }
  end
  context 'between? earlier(less) time and earlier(less) time' do
    it { base_time.between?(earlier_time, earlier_time).should be_falsey }
  end
  context 'between? earlier(less) time and later(greater) time' do
    it { base_time.between?(earlier_time, later_time).should be_truthy }
  end
  context 'between? later(greater) time and earlier(less) time' do
    it { base_time.between?(later_time, earlier_time).should be_falsey }
  end
  context 'between? same time and later(greater) time' do
    it { base_time.between?(base_time, later_time).should be_truthy }
  end
  context 'between? same time and earlier(less) time' do
    it { base_time.between?(base_time, earlier_time).should be_falsey }
  end
  context 'between? later(greater) time and same time' do
    it { base_time.between?(later_time, base_time).should be_falsey }
  end
  context 'between? earlier(less) time and same time' do
    it { base_time.between?(earlier_time, base_time).should be_truthy }
  end
  context 'between? same time and same time' do
    it { base_time.between?(base_time, base_time).should be_truthy }
  end
end
