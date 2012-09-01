# encoding: utf-8

module Vanadiel
  # Vanadiel::Moon has some constants about Vana'diel moon phases (12 steps version).
  #
  # moon phase (0..11, for Japanese service)
  module Moon
    # 新月
    NEW_MOON         = 0
    # 三日月
    WAXING_CRESCENT1 = 1
    # 七日月
    WAXING_CRESCENT2 = 2
    # 上弦の月
    FIRST_QUARTER    = 3
    # 十日夜
    WAXING_GIBBOUS1  = 4
    # 十三夜
    WAXING_GIBBOUS2  = 5
    # 満月
    FULL_MOON        = 6
    # 十六夜
    WANING_GIBBOUS1  = 7
    # 居待月
    WANING_GIBBOUS2  = 8
    # 下弦の月
    LAST_QUARTER     = 9
    # 二十日余月
    WANING_CRESCENT1 = 10
    # 二十六夜
    WANING_CRESCENT2 = 11

    # Moon phase names
    MOONNAMES = [
      'New Moon',
      'Waxing Crescent',
      'Waxing Crescent',
      'First Quarter',
      'Waxing Gibbous',
      'Waxing Gibbous',
      'Full Moon',
      'Waning Gibbous',
      'Waning Gibbous',
      'Last Quarter',
      'Waning Crescent',
      'Waning Crescent',
    ]

    # Moon phase names for Japanese
    MOONNAMES_JA = [
      '新月',
      '三日月',
      '七日月',
      '上弦の月',
      '十日夜',
      '十三夜',
      '満月',
      '十六夜',
      '居待月',
      '下弦の月',
      '二十日余月',
      '二十六夜',
    ]
  end

  # Vanadiel::Moon7 has some constants about Vana'diel moon phases (8 steps version).
  #
  # moon phase (0..7, for Non-Japanese service)
  module Moon7
    NEW_MOON        = 0
    WAXING_CRESCENT = 1
    FIRST_QUARTER   = 2
    WAXING_GIBBOUS  = 3
    FULL_MOON       = 4
    WANING_GIBBOUS  = 5
    LAST_QUARTER    = 6
    WANING_CRESCENT = 7

    # Moon phase names
    MOONNAMES = [
      'New Moon',
      'Waxing Crescent',
      'First Quarter',
      'Waxing Gibbous',
      'Full Moon',
      'Waning Gibbous',
      'Last Quarter',
      'Waning Crescent',
    ]
  end
end
