# encoding: utf-8

require 'vanadiel/time'

et = Time.now
vt = Vanadiel::Time.at(et)

puts "Earth    : %s" % et.strftime("%Y-%m-%d %H:%M:%S %A")
puts "Vana'diel: %s" % vt.strftime("%Y-%m-%d %H:%M:%S %A")
puts "           %s %s (%d%%)" % [Vanadiel::Moon::MOONNAMES_JA[vt.moon_age],
                                  Vanadiel::Moon::MOONNAMES[vt.moon_age],
                                  vt.moon_percent]
