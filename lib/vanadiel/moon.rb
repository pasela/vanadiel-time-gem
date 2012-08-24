# encoding: utf-8

module Vanadiel
  # moon phase (0-11, for Japanese client)
  module Moon
    NEW_MOON         = 0  # 新月
    WAXING_CRESCENT1 = 1  # 三日月
    WAXING_CRESCENT2 = 2  # 七日月
    FIRST_QUARTER    = 3  # 上弦の月
    WAXING_GIBBOUS1  = 4  # 十日夜
    WAXING_GIBBOUS2  = 5  # 十三夜
    FULL_MOON        = 6  # 満月
    WANING_GIBBOUS1  = 7  # 十六夜
    WANING_GIBBOUS2  = 8  # 居待月
    LAST_QUARTER     = 9  # 下弦の月
    WANING_CRESCENT1 = 10 # 二十日余月
    WANING_CRESCENT2 = 11 # 二十六夜

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

  # moon phase (0-7, for Non-Japanese client)
  module Moon7
    NEW_MOON        = 0
    WAXING_CRESCENT = 1
    FIRST_QUARTER   = 2
    WAXING_GIBBOUS  = 3
    FULL_MOON       = 4
    WANING_GIBBOUS  = 5
    LAST_QUARTER    = 6
    WANING_CRESCENT = 7

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
